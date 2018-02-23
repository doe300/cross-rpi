FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive
RUN dpkg --add-architecture armhf \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      sudo git wget curl cmake bc \
      automake libtool build-essential pkg-config make \
      apt-utils ca-certificates devscripts clang-3.9 python unzip

ADD get_url.py /tmp/get_url.py

RUN curl "https://circleci.com/api/v1.1/project/github/nomaddo/SPIRV-LLVM-circleci/latest/artifacts?branch=master&filter=successful" --output /tmp/dump \
 && wget -O /tmp/archive.zip $(python /tmp/get_url.py "archive" "/tmp/dump") \
 && unzip /tmp/archive.zip -d /opt \
 && rm /tmp/archive.zip /tmp/dump /tmp/get_url.py

ENV SYSROOT_CROSS /usr/arm-linux-gnueabihf
ENV RPI_TARGET armv6-rpi-linux-gnueabihf
ENV RPI_FIRMWARE_BASE_URL http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware
ENV RPI_FIRMWARE_VERSION 20170811-1

# rpi firmware
RUN wget -O /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
   ${RPI_FIRMWARE_BASE_URL}/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
 && wget -O /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
   ${RPI_FIRMWARE_BASE_URL}/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
 && dpkg-deb -x /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb ${SYSROOT_CROSS} \
 && dpkg-deb -x /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb ${SYSROOT_CROSS} \
 && rm /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb

RUN cd /usr/bin && ln -s arm-linux-gnueabihf-g++-6 arm-linux-gnueabihf-g++ \
 && ln -s arm-linux-gnueabihf-gcc-6 arm-linux-gnueabihf-gcc

RUN apt-get install -y --no-install-recommends libllvm3.9:armhf llvm-3.9-dev:armhf \
    opencl-c-headers:armhf gcc-6-arm-linux-gnueabihf g++-6-arm-linux-gnueabihf \
    ocl-icd-opencl-dev:armhf ocl-icd-dev:armhf \
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
