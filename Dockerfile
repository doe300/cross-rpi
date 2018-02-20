FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
      sudo git wget curl cmake bc \
      gcc g++ automake libtool build-essential pkg-config \
      make python opencl-c-headers \
      apt-utils ca-certificates devscripts \
      clang-3.9 llvm-3.9-dev llvm \
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN wget -O /tmp/master.tar.gz http://github.com/raspberrypi/tools/archive/master.tar.gz \
  && tar xf /tmp/master.tar.gz \
  && mkdir -p /opt/raspberrypi \
  && mv tools-master /opt/raspberrypi/tools \
  && rm /tmp/master.tar.gz

ENV SYSROOT_CROSS /opt/raspberrypi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/arm-linux-gnueabihf/

ENV RPI_TARGET armv6-rpi-linux-gnueabihf
ENV RPI_FIRMWARE_BASE_URL http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware
ENV RPI_FIRMWARE_VERSION 20170811-1

# rpi firmware
RUN wget -O /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
   ${RPI_FIRMWARE_BASE_URL}/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
 && wget -O /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
   ${RPI_FIRMWARE_BASE_URL}/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
 && dpkg-deb -x /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
 && cp -r /usr/include/CL ${SYSROOT_CROSS}/include \
 && apt-get remove opencl-c-headers -y

# LLVM library and headers for linking (ARM version)
RUN wget -O /tmp/libllvm-3.9.deb http://archive.raspberrypi.org/debian/pool/main/l/llvm-toolchain-3.9/libllvm3.9_3.9-4_armhf.deb \
 && wget -O /tmp/libllvm-3.9-dev.deb http://archive.raspberrypi.org/debian/pool/main/l/llvm-toolchain-3.9/llvm-3.9-dev_3.9-4_armhf.deb \
 && dpkg-deb -x	/tmp/libllvm-3.9.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x	/tmp/libllvm-3.9-dev.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libllvm-3.9.deb /tmp/libllvm-3.9-dev.deb

# Additional system libraryries required for linking LLVM
RUN wget -O /tmp/libtinfo5.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libtinfo5_5.9+20140913-1+deb8u2_armhf.deb \
 && wget -O /tmp/libncurses5.deb http://mirrordirector.raspbian.org/raspbian/pool/main/n/ncurses/libncurses5_5.9+20140913-1+deb8u2_armhf.deb \
 && wget -O /tmp/libzlib1g.deb http://mirrordirector.raspbian.org/raspbian/pool/main/z/zlib/zlib1g_1.2.8.dfsg-2_armhf.deb \
 && wget -O /tmp/libffi6.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi6_3.2.1-8_armhf.deb \
 && wget -O /tmp/libffi6-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libf/libffi/libffi-dev_3.2.1-8_armhf.deb \
 && wget -O /tmp/libedit2.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit2_3.1-20170329-1_armhf.deb \
 && wget -O /tmp/libedit2-dev.deb http://mirrordirector.raspbian.org/raspbian/pool/main/libe/libedit/libedit-dev_2.11-20080614-5_armhf.deb \
 && dpkg-deb -x /tmp/libtinfo5.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libncurses5.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libzlib1g.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi6.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libffi6-dev.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2.deb ${SYSROOT_CROSS}/ \
 && dpkg-deb -x /tmp/libedit2-dev.deb ${SYSROOT_CROSS}/ \
 && rm /tmp/libtinfo5.deb /tmp/libncurses5.deb /tmp/libzlib1g.deb /tmp/libffi6.deb /tmp/libffi6-dev.deb /tmp/libedit2.deb /tmp/libedit2-dev.deb

# SPIV-LLVM
ENV CLANG_GIT_URL http://github.com/KhronosGroup/SPIR
ENV SPIRV_GIT_URL http://github.com/KhronosGroup/SPIRV-LLVM.git

RUN git clone -b khronos/spirv-3.6.1 ${SPIRV_GIT_URL} /opt/SPIRV-LLVM \
 && git clone -b spirv-1.0 ${CLANG_GIT_URL} /opt/SPIRV-LLVM/tools/clang \
 && rm -rf /opt/SPIRV-LLVM/.git /opt/SPIRV-LLVM/tools/clang/.git

RUN mkdir -p /opt/SPIRV-LLVM/build \
 && cd /opt/SPIRV-LLVM/build \
 && cmake ../ -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_RUNTIME=Off -DLLVM_INCLUDE_TESTS=Off \
      -DLLVM_INCLUDE_EXAMPLES=Off -DLLVM_ENABLE_BACKTRACES=Off -DLLVM_TARGETS_TO_BUILD=X86 \
 && make -j14 \
 && rm -rf `ls /opt/SPIRV-LLVM/build | grep -v bin`
