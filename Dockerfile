FROM idein/cross-rpi:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ARG RPI_TARGET=armv6-rpi-linux-gnueabihf

# Enable backport repositories to provide clang/llvm 11 for buster
# For some strange reason, sudo does not work here...
USER root
RUN echo "deb http://ftp.debian.org/debian buster-backports main" > /etc/apt/sources.list.d/buster-backports.list \
    && echo "deb http://ftp.debian.org/debian buster-backports-sloppy main" > /etc/apt/sources.list.d/buster-backports-sloppy.list

USER idein
RUN sudo apt-get update \
 && sudo apt-get upgrade -y \
 && sudo apt-get install -y --no-install-recommends \
      sudo git wget curl cmake bc \
      gcc g++ automake libtool build-essential pkg-config \
      make python opencl-c-headers \
      apt-utils ca-certificates devscripts unzip \
      clang-11 llvm-11-dev llvm-11 libclang1-11 libclang-11-dev \
 && sudo apt-get clean && sudo rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ENV SYSROOT_CROSS ${HOME}/cross

# LLVM library and headers for linking (ARM version)
RUN wget -O /tmp/libllvm-11.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-11/libllvm11_11.0.1-2+rpi1_armhf.deb \
 && wget -O /tmp/llvm-11-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-11/llvm-11-dev_11.0.1-2+rpi1_armhf.deb \
 && wget -O /tmp/llvm-11.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-11/llvm-11_11.0.1-2+rpi1_armhf.deb \
 && wget -O /tmp/llvm-11-tools.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-11/llvm-11-tools_11.0.1-2+rpi1_armhf.deb \
 && wget -O /tmp/llvm-11-runtime.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-11/llvm-11-runtime_11.0.1-2+rpi1_armhf.deb \
 && dpkg-deb -x	/tmp/libllvm-11.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-11-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-11.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-11-tools.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-11-runtime.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/*.deb \
 && touch ${HOME}/cross/usr/lib/llvm-11/bin/lli # create dummy file

RUN sed -i -e "s|/usr/lib|/home/idein/cross/usr/lib|p" /home/idein/cross/usr/lib/llvm-11/cmake/LLVMConfig.cmake

# Additional system libraryries required for linking LLVM
RUN wget -O /tmp/libtinfo6.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libtinfo6_6.3-2_armhf.deb \
 && wget -O /tmp/libncurses6.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libncurses6_6.3-2_armhf.deb \
 && wget -O /tmp/libzlib1g.deb http://mirrordirector.raspbian.org/raspbian/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2_armhf.deb \
 && wget -O /tmp/libffi6.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi6_3.2.1-9_armhf.deb \
 && wget -O /tmp/libffi6-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi-dev_3.2.1-9_armhf.deb \
 && wget -O /tmp/libedit2.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit2_3.1-20210910-1_armhf.deb \
 && wget -O /tmp/libedit2-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit-dev_3.1-20210910-1_armhf.deb \
 && wget -O /tmp/libz3.deb http://mirrordirector.raspbian.org/raspbian/pool/main/z/z3/libz3-4_4.8.12-1_armhf.deb \
 && wget -O /tmp/libz3-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/z/z3/libz3-dev_4.8.12-1_armhf.deb \
 && wget -O /tmp/libpfm4.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libp/libpfm4/libpfm4_4.11.1+git32-gd0b85fb-1_armhf.deb \
 && dpkg-deb -x /tmp/libtinfo6.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libncurses6.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libzlib1g.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi6.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi6-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libz3.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libz3-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libpfm4.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/*.deb

RUN wget -O /tmp/ocl-icd-opencl-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-opencl-dev_2.2.14-3_armhf.deb \
 && wget -O /tmp/ocl-icd-libopencl1.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-libopencl1_2.2.14-3_armhf.deb \
 && wget -O /tmp/opencl-c-headers.deb http://mirrordirector.raspbian.org/raspbian/pool/main/k/khronos-opencl-headers/opencl-c-headers_3.0~2022.01.04-1_all.deb \
 && wget -O /tmp/ocl-icd-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-dev_2.2.14-3_armhf.deb \
 && dpkg-deb -x /tmp/ocl-icd-opencl-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/ocl-icd-libopencl1.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/opencl-c-headers.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/ocl-icd-dev.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/*.deb

# Additional packages required to fulfill dependencies
RUN wget -O /tmp/libncurses-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libncurses-dev_6.3-2_armhf.deb \
 && dpkg-deb -x /tmp/libncurses-dev.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/*.deb
