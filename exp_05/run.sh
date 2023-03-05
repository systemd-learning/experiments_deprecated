#!/bin/bash

BASE=`pwd`
QEMU=${BASE}/../tools/qemu
DEPLOY=${BASE}/deploy

${QEMU}/qemu-system-aarch64 \
	-L ${QEMU}/pc-bios/  \
	-m 1G -M virt -nographic -cpu cortex-a57 \
	-kernel ${DEPLOY}/Image.gz \
	-drive format=raw,file=${DEPLOY}/disk.img,if=virtio \
	-initrd ${DEPLOY}/rootfs.gz \
	-append "console=ttyAMA0 rdinit=/sbin/init " 
