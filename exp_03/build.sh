#!/bin/bash

source ../common/env.sh
source ../common/functions.sh

CROSS_PREFIX=${CROSS_PREFIX_ARM}

TARGET_ARCH=arm
TARGET_CFG=vexpress_defconfig
TARGET_IMG=zImage
TARGET_DTB=vexpress-v2p-ca9.dtb
INITRAMFS=root.gz
DISK=disk.img

make_initramfs() {
	pushd ${ROOTFS}/
	add_procfs_sysfs_devfs_rcS

	rm -f sbin/init
	cat > sbin/init <<EOF
#!/bin/sh

set -x

/bin/mount -a
/sbin/mdev -s
sleep 2
/bin/mount /dev/mmcblk0 /mnt
exec switch_root /mnt /sbin/init
EOF
	chmod +x sbin/init
	find . | cpio -o -H newc | gzip -9 > ${DEPLOY}/${INITRAMFS}
	popd
}

make_diskimg() {
	dd if=/dev/zero of=${DEPLOY}/${DISK} bs=1024k count=32
	mkfs.ext2 -F -m0 ${DEPLOY}/${DISK}
	sudo mount -t ext2 -o loop ${DEPLOY}/${DISK}  ${MNT}

	pushd ${ROOTFS}/
	pushd sbin
	rm -f init
	ln -s ../bin/busybox init
	popd
	sudo cp -r * ${MNT}
	popd

	sudo sync
	sudo umount  ${MNT}
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

# initramfs & disk.img
make_initramfs
make_diskimg

