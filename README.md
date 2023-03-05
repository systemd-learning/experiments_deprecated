
- download

$ git clone https://github.com/w-simon/little-experiments.git && cd little-experiments

- init submodules

$ git submodule update --init --recursive

- prepare crosstools (from https://mirrors.tuna.tsinghua.edu.cn/armbian-releases/_toolchain/)

$ cd tools && bash prepare_cross_tools.sh && cd -

- prepare linux src

$ cd packages/linux && bash init_kernel_src.sh && cd -
