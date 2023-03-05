#! /bin/bash

source ../common/env.sh

ARM_TOOL_CHAIN=${ARM_CROSS_VER}.tar.xz
ARM64_TOOL_CHAIN=${ARM64_CROSS_VER}.tar.xz

mkdir -p cross && pushd cross && \
wget https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/_toolchain/${ARM64_TOOL_CHAIN} && \
wget https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/_toolchain/${ARM_TOOL_CHAIN}   && \
tar xfJ ${ARM_TOOL_CHAIN} && tar xfJ ${ARM64_TOOL_CHAIN}  && \
popd

