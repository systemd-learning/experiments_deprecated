#!/bin/bash

BASE=`pwd`
QEMU=${BASE}/../tools/qemu
DEPLOY=${BASE}/deploy

${QEMU}/qemu-system-arm \
	-m 128M \
	-M vexpress-a9 \
	-kernel ${DEPLOY}/zImage \
	-dtb ${DEPLOY}/vexpress-v2p-ca9.dtb \
	-initrd ${DEPLOY}/root.gz \
	-drive format=raw,file=${DEPLOY}/disk.img,if=sd \
	-nographic \
	--append "console=ttyAMA0 debug rdinit=/sbin/init "
