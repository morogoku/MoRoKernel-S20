#!/bin/bash
#
# MoRoKernel Build Script for S20
#

make mrproper
rm -fR out 2>/dev/null
mkdir out 2>/dev/null

VARIANT=y2sxxx

export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export ARCH=arm64

DTB_DIR=$(pwd)/out/arch/$ARCH/boot/dts
rm ${DTB_DIR}/exynos/* ${DTB_DIR}/samsung/* 2>/dev/null

BUILD_CROSS_COMPILE=$(pwd)/../toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
BUILD_CC=$(pwd)/../toolchains/clang-9.0.3-r353983c/bin/clang
BUILD_CLANG_TRIPLE=aarch64-linux-gnu-


(
make -j$(nproc) ARCH=$ARCH -C $(pwd) O=$(pwd)/out \
		exynos9830-${VARIANT}_defconfig || exit -1

make -j$(nproc) ARCH=$ARCH -C $(pwd) O=$(pwd)/out \
		CC=$BUILD_CC \
		CLANG_TRIPLE=$BUILD_CLANG_TRIPLE \
		CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
) 2>&1 | tee -a ./out/build.log

cp $(pwd)/out/arch/$ARCH/boot/Image $(pwd)/out/Image

$(pwd)/tools/mkdtimg cfg_create $(pwd)/out/dtb.img dt.configs/exynos9830.cfg -d ${DTB_DIR}/exynos
$(pwd)/tools/mkdtimg cfg_create $(pwd)/out/dtbo.img dt.configs/${VARIANT}.cfg -d ${DTB_DIR}/samsung


