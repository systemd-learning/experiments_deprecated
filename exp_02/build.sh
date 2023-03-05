#!/bin/bash

source ../common/env.sh
source ../common/functions.sh

CROSS_PREFIX=${CROSS_PREFIX_ARM}

TARGET_ARCH=arm
TARGET_IMG=zImage
TARGET_DTB=vexpress-v2p-ca9.dtb
INITRD=initrd.img


# support ramdisk 
#CONFIG_BLK_DEV_RAM=y
#CONFIG_BLK_DEV_RAM_COUNT=16
#CONFIG_BLK_DEV_RAM_SIZE=4096

config_kernel() {
	cd ${BASE}/../linux/src
	make ARCH=arm vexpress_defconfig O=${BUILD_KERNEL}
	cd ${BUILD_KERNEL}
	sed -i 's/# CONFIG_BLK_DEV_RAM is not set/CONFIG_BLK_DEV_RAM=y/' .config
	sed -i '/CONFIG_BLK_DEV_RAM=y/a\CONFIG_BLK_DEV_RAM_COUNT=16'  .config
	sed -i '/CONFIG_BLK_DEV_RAM=y/a\CONFIG_BLK_DEV_RAM_SIZE=4096' .config
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

# initrd
make_initrd

