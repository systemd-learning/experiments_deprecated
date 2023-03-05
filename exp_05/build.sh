#!/bin/bash

source ../common/env.sh
source ../common/functions.sh

CROSS_PREFIX=${CROSS_PREFIX_ARM64}

TARGET_ARCH=arm64
TARGET_CFG=defconfig
TARGET_IMG=Image.gz
TARGET_DTB=arm/vexpress-v2f-1xv7-ca53x2.dtb
INITRAMFS=rootfs.gz
DISK=disk.img

config_busybox() {
	pushd ${BASE}/../busybox
	make ARCH=arm defconfig O=${BUILD_BUSYBOX}
	popd
}

build_glibc() {
	cd ${BUILD_BUSYBOX}
	${BASE}/../glibc/configure aarch64-none-linux-gnu --target=aarch64-none-linux-gnu --build=x86_64-pc-linux-gnu --prefix=  --enable-add-ons
	make  -j ${NR}
	make install install_root=${ROOTFS}
}

make_diskimg() {
	pushd ${DEPLOY}
	rm -f ${DISK}
	dd if=/dev/zero of=${DISK} bs=1024k count=128
	sudo sfdisk ${DISK} << EOF
1,102400,L,*
,,,,
EOF
	DEV=$(sudo losetup -f)
	sudo losetup -P ${DEV} ${DISK}
	sudo mkfs.fat -F 16 -n BOOT ${DEV}p1
	sudo mkfs.ext4 -L ROOT ${DEV}p2
	sudo mount ${DEV}p1  ${MNT}
	sudo cp ${DEPLOY}/${TARGET_IMG}  ${MNT}
	sudo cp ${DEPLOY}/*.dtb  ${MNT}
	sudo cp ${DEPLOY}/${INITRAMFS}  ${MNT}
	sudo umount  ${MNT}

	sudo mount ${DEV}p2  ${MNT}
	pushd ${ROOTFS}/
	sudo cp -r * ${MNT}
	sudo umount  ${MNT}
	popd
	sudo losetup -d ${DEV}                
}

prepare

# kernel
config_kernel
build_kernel
deploy_kernel

# glibc
build_glibc

# busybox
config_busybox
build_busybox
deploy_busybox

# initramfs & disk.img
make_initramfs
make_diskimg 

