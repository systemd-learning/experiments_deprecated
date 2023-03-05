#! /bin/bash

set -eo pipefail

BASE=`pwd`
PACKAGES=${BASE}/../packages/
BUILD_KERNEL=${BASE}/build_kernel
BUILD_BUSYBOX=${BASE}/build_busybox
BUILD_UBOOT=${BASE}/build_uboot
BUILD_GLIBC=${BASE}/build_glibc
DEPLOY=${BASE}/deploy
ROOTFS=${BASE}/rootfs
MNT=${BASE}/mnt

NR=$(grep processor /proc/cpuinfo | tail -n 1 | awk '{print $3}')

ARM_CROSS_VER=gcc-arm-11.2-2022.02-x86_64-arm-none-linux-gnueabihf
ARM64_CROSS_VER=gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu
export PATH=${BASE}/../tools/cross/${ARM_CROSS_VER}/bin/:${BASE}/../tools/cross/${ARM64_CROSS_VER}/bin/:${PATH}

CROSS_PREFIX_ARM=arm-none-linux-gnueabihf-
CROSS_PREFIX_ARM64=aarch64-none-linux-gnu-

