FROM idein/cross-rpi:armv6

ENV DEBIAN_FRONTEND noninteractive
ARG RPI_TARGET=armv6-rpi-linux-gnueabihf

# Enable backport repositories to provide clang/llvm 6 for stretch
# For some strange reason, sudo does not work here...
USER root
RUN echo "deb http://ftp.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list \
    && echo "deb http://ftp.debian.org/debian stretch-backports-sloppy main" > /etc/apt/sources.list.d/stretch-backports-sloppy.list

USER idein
RUN sudo apt-get update \
 && sudo apt-get upgrade -y \
 && sudo apt-get install -y --no-install-recommends \
      sudo git wget curl bc \
      gcc g++ automake libtool build-essential pkg-config \
      make python \
      apt-utils ca-certificates devscripts unzip \
      clang-7 llvm-7-dev llvm-7 libclang1-7 libclang-7-dev \
 && sudo apt-get install -y --no-install-recommends -t stretch-backports-sloppy \
      libarchive13 \
 && sudo apt-get install -y --no-install-recommends -t stretch-backports \
      cmake opencl-c-headers \
 && sudo apt-get clean && sudo rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ENV SYSROOT_CROSS ${HOME}/cross

# LLVM library and headers for linking (ARM version)
RUN wget -O /tmp/libllvm-7.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-7/libllvm7_7.0.1-8+rpi3_armhf.deb \
 && wget -O /tmp/llvm-7-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-7/llvm-7-dev_7.0.1-8+rpi3_armhf.deb \
 && wget -O /tmp/llvm-7.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-7/llvm-7_7.0.1-8+rpi3_armhf.deb \
 && dpkg-deb -x	/tmp/libllvm-7.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-7-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-7.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libllvm-7.deb /tmp/llvm-7-dev.deb /tmp/llvm-7.deb \
 && touch ${HOME}/cross/usr/lib/llvm-7/bin/lli # create dummy file

RUN sed -i -e "s|/usr/lib|/home/idein/cross/usr/lib|p" /home/idein/cross/usr/lib/llvm-7/cmake/LLVMConfig.cmake

# Additional system libraryries required for linking LLVM
RUN wget -O /tmp/libtinfo6.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libtinfo6_6.2-1_armhf.deb \
 && wget -O /tmp/libncurses6.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libncurses6_6.2-1_armhf.deb \
 && wget -O /tmp/libzlib1g.deb http://mirrordirector.raspbian.org/raspbian/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2_armhf.deb \
 && wget -O /tmp/libffi7.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi7_3.3-4_armhf.deb \
 && wget -O /tmp/libffi7-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi-dev_3.3-4_armhf.deb \
 && wget -O /tmp/libedit2.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit2_3.1-20191231-1_armhf.deb \
 && wget -O /tmp/libedit2-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit-dev_3.1-20191231-1_armhf.deb \
 && wget -O /tmp/libbsd.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libb/libbsd/libbsd0_0.10.0-1_armhf.deb \
 && dpkg-deb -x /tmp/libtinfo6.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libncurses6.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libzlib1g.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi7.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi7-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libbsd.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libtinfo6.deb /tmp/libncurses6.deb /tmp/libzlib1g.deb /tmp/libffi7.deb /tmp/libffi7-dev.deb /tmp/libedit2.deb /tmp/libedit2-dev.deb /tmp/libbsd.deb

RUN wget -O /tmp/ocl-icd-opencl-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-opencl-dev_2.2.12-4_armhf.deb \
 && wget -O /tmp/ocl-icd-libopencl1.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-libopencl1_2.2.12-4_armhf.deb \
 && wget -O /tmp/opencl-c-headers.deb http://mirrordirector.raspbian.org/raspbian/pool/main/k/khronos-opencl-headers/opencl-c-headers_2.1-1_all.deb \
 && wget -O /tmp/ocl-icd-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-dev_2.2.12-4_armhf.deb \
 && dpkg-deb -x /tmp/ocl-icd-opencl-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/ocl-icd-libopencl1.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/opencl-c-headers.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/ocl-icd-dev.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/*.deb

# Additional packages required to fulfill dependencies
RUN wget -O /tmp/libncurses-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libncurses-dev_6.2-1_armhf.deb \
 && dpkg-deb -x /tmp/libncurses-dev.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libncurses-dev.deb

# SPIRV-LLVM-Translator
RUN sudo git clone -b v7.0.1-1 --depth 1 https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git /opt/SPIRV-LLVM-Translator \
 && sudo mkdir /opt/SPIRV-LLVM-Translator/build && cd /opt/SPIRV-LLVM-Translator/build \
 && sudo cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_TESTS=OFF .. \
 && sudo make llvm-spirv -j `nproc` \
 && sudo rm -rf `ls ./build | grep -v tools` && sudo rm -rf .git/
