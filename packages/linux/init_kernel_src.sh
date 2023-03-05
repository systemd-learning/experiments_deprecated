#! /bin/bash

KERNEL=linux-stable-rt-5.10.65-rt53-rebase.tar.gz

wget https://git.kernel.org/pub/scm/linux/kernel/git/rt/linux-stable-rt.git/snapshot/${KERNEL} && 
mkdir src && \
tar xfz ${KERNEL} --strip-components=1 -C src && \
pushd src && git init . && git add  . && git commit -m "init code: ${KERNEL}" && popd 

