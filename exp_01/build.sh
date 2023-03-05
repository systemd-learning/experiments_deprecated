#!/bin/bash

source ../common/env.sh
source ../common/functions.sh

CROSS_PREFIX=${CROSS_PREFIX_ARM}

TARGET_ARCH=arm
TARGET_CFG=vexpress_defconfig
TARGET_IMG=zImage
TARGET_DTB=vexpress-v2p-ca9.dtb
INITRAMFS=rootfs.gz

prepare

# kernel
config_kernel
build_kernel
deploy_kernel

# busybox
config_busybox
build_busybox
deploy_busybox

# initramfs
make_initramfs
