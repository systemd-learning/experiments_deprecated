#!/bin/bash

source ../common/env.sh
CROSS_PREFIX=${CROSS_PREFIX_ARM}

IMG=zImage
DTB=vexpress-v2p-ca9.dtb
INITRD=rootfs.gz
SCR=boot.scr
DISK=disk.img

prepare() {
	mkdir -p  ${BUILD_KERNEL}
	mkdir -p  ${BUILD_BUSYBOX}
	mkdir -p  ${DEPLOY}
}

build_kernel() {
	cd ${BASE}/../linux/src
	make ARCH=arm vexpress_defconfig O=${BUILD_KERNEL}
	cd ${BUILD_KERNEL}
	make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} zImage dtbs -j ${NR}
}

build_busybox() {
	cd ${BASE}/../busybox
	make ARCH=arm defconfig O=${BUILD_BUSYBOX}
	cd ${BUILD_BUSYBOX}
	sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config
	make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} -j ${NR} install
}

build_uboot() {
	cd ${BASE}/../u-boot
	make ARCH=arm vexpress_ca9x4_defconfig O=${BUILD_UBOOT}
	cd ${BUILD_UBOOT}
	make ARCH=arm CROSS_COMPILE=${CROSS_PREFIX} -j ${NR}
}

deploy_kernel() {
	pushd ${BUILD_KERNEL}
	cp arch/arm/boot/${IMG} ${DEPLOY}/
	cp arch/arm/boot/dts/${DTB} ${DEPLOY}/
	popd
}

deploy_initrd() {
	pushd ${BUILD_BUSYBOX}/_install/
	cp -f ${BASE}/_switch_root.sh ${BUILD_BUSYBOX}/_install/bin/
	chmod +x ${BUILD_BUSYBOX}/_install/bin/_switch_root.sh
	find . | cpio -o -H newc | gzip -9 > ${DEPLOY}/${INITRD}
	rm -f ${BUILD_BUSYBOX}/_install/bin/_switch_root.sh
	popd
}

deploy_uboot() {
	pushd ${BUILD_UBOOT}
	cp u-boot ${DEPLOY}/
	popd
}

build_rootfs_skelen() {
	pushd ${BUILD_BUSYBOX}/_install/
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
/sbin/mdev -s
EOF
	chmod +x etc/init.d/rcS

	cat >etc/inittab <<EOF
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::ctrlaltdel:/bin/umount -a -r
EOF
	popd
}

make_diskimg() {
	pushd ${DEPLOY}
	rm -f ${DISK}
	dd if=/dev/zero of=${DISK} bs=1024k count=32
	sudo sfdisk ${DISK} << EOF
1,20480,L,*
,,,,
EOF
	mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "boot script" -d ../cmd.txt boot.scr
	DEV=$(sudo losetup -f)
	sudo losetup -P ${DEV} ${DISK}
	sudo mkfs.fat -F 16 -n BOOT ${DEV}p1
	sudo mkfs.ext4 -L ROOT ${DEV}p2

	sudo mount ${DEV}p1 /mnt
	sudo cp ${DEPLOY}/${IMG} /mnt/
	sudo cp ${DEPLOY}/${DTB} /mnt/
	sudo cp ${DEPLOY}/${SCR} /mnt/
	sudo cp ${DEPLOY}/${INITRD} /mnt/
	sudo umount /mnt

	sudo mount ${DEV}p2 /mnt
	pushd ${BUILD_BUSYBOX}/_install/
	sudo cp -r * /mnt/
	sudo umount /mnt
	popd

	sudo losetup -d ${DEV}
}

prepare

# kernel
config_kernel
build_kernel
deploy_kernel

# busybox
config_busybox
build_busybox
deploy_busybox

# uboot
build_uboot
deploy_uboot

# initramfs &  diskimg
build_rootfs_skelen
deploy_initramfs
make_diskimg

