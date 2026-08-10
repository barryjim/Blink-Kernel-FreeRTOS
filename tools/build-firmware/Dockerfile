FROM ubuntu:22.04

LABEL maintainer="Embedded Build Tools"
LABEL description="Embedded firmware build environment for Silicon Labs MG301"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    gcc-arm-none-eabi \
    g++-arm-none-eabi \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    git \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir \
    pyyaml \
    jinja2

RUN mkdir -p /opt/simplicity-sdk

ENV CC=arm-none-eabi-gcc
ENV CXX=arm-none-eabi-g++
ENV AR=arm-none-eabi-ar
ENV OBJCOPY=arm-none-eabi-objcopy
ENV SIZE=arm-none-eabi-size
ENV STRIP=arm-none-eabi-strip
ENV CMAKE_MAKE_PROGRAM=ninja

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]