#!/bin/bash

source ../common/env.sh

prepare() {
	mkdir -p  ${BUILD_KERNEL}
	mkdir -p  ${BUILD_BUSYBOX}
	mkdir -p  ${MNT}
	mkdir -p  ${DEPLOY}
	mkdir -p  ${ROOTFS}
}

config_kernel() {
	pushd ${PACKAGES}/linux/src
	make ARCH=${TARGET_ARCH} ${TARGET_CFG} O=${BUILD_KERNEL}
	popd
}

build_kernel() {
	pushd ${BUILD_KERNEL}
	make ARCH=${TARGET_ARCH} CROSS_COMPILE=${CROSS_PREFIX} ${TARGET_IMG} modules dtbs -j ${NR}
	popd
}

deploy_kernel() {
	pushd ${BUILD_KERNEL}
	cp arch/${TARGET_ARCH}/boot/${TARGET_IMG} ${DEPLOY}/
	cp arch/${TARGET_ARCH}/boot/dts/${TARGET_DTB} ${DEPLOY}/
	make INSTALL_MOD_PATH=${ROOTFS} INSTALL_MOD_STRIP=1 modules_install 
	popd
}

config_busybox() {
	pushd ${PACKAGES}/busybox
	make ARCH=arm defconfig O=${BUILD_BUSYBOX}
	popd

	pushd ${BUILD_BUSYBOX}
	sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config
	popd
}

build_busybox() {
	pushd ${BUILD_BUSYBOX}
	make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} -j ${NR}
	popd
}

deploy_busybox() {
	pushd ${BUILD_BUSYBOX}
	make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} -j ${NR} install CONFIG_PREFIX=${ROOTFS}
	popd
}

add_procfs_sysfs_devfs_rcS() {
	pushd ${ROOTFS}

	mkdir -p proc
	mkdir -p sys
	mkdir -p dev
	mkdir -p etc
	mkdir -p mnt

	cat >etc/fstab <<EOF
proc		/proc	proc	defaults    0	0
sys		/sys	sysfs	defaults    0	0
EOF

	mkdir -p etc/init.d/
	cat >etc/init.d/rcS <<EOF
#!/bin/sh

/bin/mount -a
EOF
	chmod +x etc/init.d/rcS

	cat >etc/inittab <<EOF
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF
	popd
}

make_initramfs() {
	add_procfs_sysfs_devfs_rcS

	pushd ${ROOTFS}
	find . | cpio -o -H newc | gzip -9 > ${DEPLOY}/${INITRAMFS}
	popd
}

make_initrd() {
	add_procfs_sysfs_devfs_rcS

	dd if=/dev/zero of=${DEPLOY}/${INITRD} bs=1024k count=4
	mkfs.ext2 -F -m0 ${DEPLOY}/${INITRD}

	sudo mount -t ext2 -o loop ${DEPLOY}/${INITRD} ${MNT}
	sudo cp -r ${ROOTFS}/* ${MNT}
	sudo umount ${MNT}
}

