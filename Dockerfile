FROM idein/cross-rpi:armv6

ENV DEBIAN_FRONTEND noninteractive
ARG RPI_TARGET=armv6-rpi-linux-gnueabihf

RUN sudo apt-get update \
 && sudo apt-get upgrade -y \
 && sudo apt-get install -y --no-install-recommends \
      sudo git wget curl cmake bc \
      gcc g++ automake libtool build-essential pkg-config \
      make python opencl-c-headers \
      apt-utils ca-certificates devscripts \
      clang-3.9 llvm-3.9-dev llvm unzip \
 && sudo apt-get clean && sudo rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ENV SYSROOT_CROSS ${HOME}/cross

# LLVM library and headers for linking (ARM version)
RUN wget -O /tmp/libllvm-3.9.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-3.9/libllvm3.9_3.9.1-19+rpi1_armhf.deb \
 && wget -O /tmp/llvm-3.9-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-3.9/llvm-3.9-dev_3.9.1-19+rpi1_armhf.deb \
 && wget -O /tmp/llvm-3.9.deb http://mirrordirector.raspbian.org/raspbian/pool/main/l/llvm-toolchain-3.9/llvm-3.9_3.9.1-19+rpi1_armhf.deb \
 && dpkg-deb -x	/tmp/libllvm-3.9.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-3.9-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/llvm-3.9.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libllvm-3.9.deb /tmp/llvm-3.9-dev.deb /tmp/llvm-3.9.deb \
 && touch ${HOME}/cross/usr/lib/llvm-3.9/bin/lli # create dummy file

RUN sed -i -e "s|/usr/lib|/home/idein/cross/usr/lib|p" /home/idein/cross/usr/lib/llvm-3.9/cmake/LLVMConfig.cmake

# Additional system libraryries required for linking LLVM
RUN wget -O /tmp/libtinfo5.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libtinfo5_6.0+20161126-1+deb9u2_armhf.deb \
 && wget -O /tmp/libncurses5.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libncurses5_5.9+20140913-1+deb8u2_armhf.deb \
 && wget -O /tmp/libzlib1g.deb http://mirrordirector.raspbian.org/raspbian/pool/main/z/zlib/zlib1g_1.2.8.dfsg-2_armhf.deb \
 && wget -O /tmp/libffi6.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi6_3.2.1-8_armhf.deb \
 && wget -O /tmp/libffi6-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi-dev_3.2.1-8_armhf.deb \
 && wget -O /tmp/libedit2.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit2_3.1-20170329-1_armhf.deb \
 && wget -O /tmp/libedit2-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit-dev_2.11-20080614-5_armhf.deb \
 && wget -O /tmp/libbsd.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libb/libbsd/libbsd0_0.8.3-1_armhf.deb \
 && dpkg-deb -x /tmp/libtinfo5.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libncurses5.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libzlib1g.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi6.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi6-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libbsd.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libtinfo5.deb /tmp/libncurses5.deb /tmp/libzlib1g.deb /tmp/libffi6.deb /tmp/libffi6-dev.deb /tmp/libedit2.deb /tmp/libedit2-dev.deb /tmp/libbsd.deb

RUN wget -O /tmp/ocl-icd-opencl-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-opencl-dev_2.2.11-1_armhf.deb \
 && wget -O /tmp/ocl-icd-libopencl1.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-libopencl1_2.2.11-1_armhf.deb \
 && wget -O /tmp/opencl-c-headers.deb http://mirrordirector.raspbian.org/raspbian/pool/main/k/khronos-opencl-headers/opencl-c-headers_2.1-1_all.deb \
 && wget -O /tmp/ocl-icd-opencl-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-opencl-dev_2.2.11-1_armhf.deb \
 && wget -O /tmp/ocl-icd-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/o/ocl-icd/ocl-icd-dev_2.2.11-1_armhf.deb \
 && dpkg-deb -x /tmp/ocl-icd-opencl-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/ocl-icd-libopencl1.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/opencl-c-headers.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/ocl-icd-opencl-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/ocl-icd-dev.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/*.deb

# SPIV-LLVM
ADD get_url.py /tmp/get_url.py
RUN curl "https://circleci.com/api/v1.1/project/github/nomaddo/SPIRV-LLVM-circleci/latest/artifacts?branch=master&filter=successful" --output /tmp/dump \
 && wget -O /tmp/archive.zip $(python /tmp/get_url.py "archive" "/tmp/dump") \
 && sudo unzip -q /tmp/archive.zip -d /opt \
 && sudo rm /tmp/archive.zip /tmp/dump /tmp/get_url.py
