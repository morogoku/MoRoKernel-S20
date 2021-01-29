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

export LOCALVERSION="-MoRoKernel-G986B-v0.2"

DTB_DIR=$(pwd)/out/arch/$ARCH/boot/dts
rm ${DTB_DIR}/exynos/* ${DTB_DIR}/samsung/* 2>/dev/null

BUILD_CROSS_COMPILE=$(pwd)/../toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
BUILD_CC=$(pwd)/../toolchains/clang-9.0.3-r353983c/bin/clang
BUILD_CLANG_TRIPLE=aarch64-linux-gnu-


(
START_TIME=`date +%s`

make -j$(nproc) ARCH=$ARCH -C $(pwd) O=$(pwd)/out \
		exynos9830-${VARIANT}_defconfig || exit -1

make -j$(nproc) ARCH=$ARCH -C $(pwd) O=$(pwd)/out \
		CC=$BUILD_CC \
		CLANG_TRIPLE=$BUILD_CLANG_TRIPLE \
		CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

cp $(pwd)/out/arch/$ARCH/boot/Image $(pwd)/out/Image

$(pwd)/tools/mkdtimg cfg_create $(pwd)/out/dtb.img dt.configs/exynos9830.cfg -d ${DTB_DIR}/exynos
$(pwd)/tools/mkdtimg cfg_create $(pwd)/out/dtbo.img dt.configs/${VARIANT}.cfg -d ${DTB_DIR}/samsung

END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo -e "\e[1;32mTotal compile time is $ELAPSED_TIME seconds\e[0m"
echo ""
) 2>&1 | tee -a ./out/build.log




