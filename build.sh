#!/bin/bash
#
# MoRoKernel Build Script for S20
#



# DEFINE VARIABLES
# ----------------

export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export ARCH=arm64

BUILD_CROSS_COMPILE=$PWD/../toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-
BUILD_CC=$PWD/../toolchains/clang-9.0.3-r353983c/bin/clang
BUILD_CLANG_TRIPLE=aarch64-linux-gnu-

OUTDIR=$PWD/out
DTB_DIR=$OUTDIR/arch/$ARCH/boot/dts

K_VERSION="v0"
K_BASE="CUA3"
K_NAME="MoRoKernel"
export KBUILD_BUILD_VERSION="1"
export LOCALVERSION="-$K_NAME-G986B-$KVERSION"



# FUNCTIONS
# ---------

FUNC_DELETE_PLACEHOLDERS()
{
	find . -name \.placeholder -type f -delete
	echo ""
        echo "Placeholders Deleted from Ramdisk"
}

FUNC_CLEAN()
{
	make mrproper
	#rm ${DTB_DIR}/exynos/* ${DTB_DIR}/samsung/* 2>/dev/null
}

FUNC_BUILD_KERNEL()
{
	echo ""
	echo "Defconfig: $DEFCONFIG for $VARIANT $DEVICE"
        
	cp -f $PWD/arch/$ARCH/configs/exynos9830_defconfig $PWD/arch/$ARCH/configs/tmp_defconfig
	cat $PWD/arch/$ARCH/configs/$DEFCONFIG >> $PWD/arch/$ARCH/configs/tmp_defconfig

	echo ""
	echo "Compiling kernel"

	make -j$(nproc) ARCH=$ARCH -C $PWD O=$OUTDIR tmp_defconfig

	make -j$(nproc) ARCH=$ARCH -C $PWD O=$OUTDIR \
			CC=$BUILD_CC \
			CLANG_TRIPLE=$BUILD_CLANG_TRIPLE \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE
	
	rm -f $PWD/arch/$ARCH/configs/tmp_defconfig
}

FUNC_BUILD_DTB()
{
	echo ""
	echo "Creating dtb.img"

	$PWD/tools/mkdtimg cfg_create $OUTDIR/dtb.img dt.configs/exynos9830.cfg -d ${DTB_DIR}/exynos
}

FUNC_BUILD_DTBO()
{
	echo ""
	echo "Creating dtbo.img"

	$PWD/tools/mkdtimg cfg_create $OUTDIR/dtbo.img dt.configs/${VARIANT}.cfg -d ${DTB_DIR}/samsung
}

FUNC_BUILD_RAMDISK()
{
	echo ""
	echo "Building Ramdisk"

	cd $PWD/build
	mkdir -p $OUTDIR/build/temp 2>/dev/null
	cp -rf aik/. $OUTDIR/build/temp
	
	cp -rf ramdisk/ramdisk/. $OUTDIR/build/temp/ramdisk
	cp -rf ramdisk/split_img/. $OUTDIR/build/temp/split_img
	
	rm -f temp/split_img/boot.img-zImage 2>/dev/null
	rm -f temp/split_img/boot.img-dtb 2>/dev/null

	cp $OUTDIR/arch/$ARCH/boot/Image temp/split_img/boot.img-zImage
	cp $OUTDIR/arch/$ARCH/boot/dtb.img temp/split_img/boot.img-dtb
	cd temp

	echo "Device: $DEVICE"

	./repackimg.sh

	echo SEANDROIDENFORCE >> image-new.img
	mkdir $OUTDIR/build/kernel-temp 2>/dev/null
	mv image-new.img $OUTDIR/build/kernel-temp/$DEVICE-boot.img
	rm -rf $OUTDIR/build/temp
}

FUNC_BUILD_FLASHABLES()
{
	cd $OUTDIR/build
	mkdir temp
	cp -rf $PWD/build/zip/. temp
	cd $OUTDIR/build/kernel-temp
	echo ""
	echo "Compressing kernels..."
	tar cv * | xz -9 > ../temp/moro/kernel.tar.xz

	cd $OUTDIR/build/temp
	zip -9 -r ../$ZIP_NAME *

	cd ..
	rm -rf temp kernel-temp ramdisk-temp 2>/dev/null
}

FUNC_INFO()
{
	echo ""
	echo -e "\e[1;34m**********************************\e[1;32m"
	echo " DEVICE: $DEVICE $VARIANT"
	echo " DEFCONFIG: $DEFCONFIG"
	echo -e "\e[1;34m**********************************\e[0m"
	echo ""
}

MAIN()
{
	rm -fR $OUTDIR 2>/dev/null
	mkdir $OUTDIR 2>/dev/null

	(
		START_TIME=`date +%s`
		FUNC_INFO
		FUNC_DELETE_PLACEHOLDERS
		FUNC_CLEAN
		FUNC_BUILD_KERNEL
		FUNC_BUILD_DTB
		#FUNC_BUILD_DTBO
		END_TIME=`date +%s`
		let "ELAPSED_TIME=$END_TIME-$START_TIME"
		echo ""
		echo -e "\e[1;32mTotal compile time is $ELAPSED_TIME seconds\e[0m"
		echo ""
	) 2>&1 | tee -a $OUTDIR/$DEVICE-build.log
}


# PROGRAM START
# -------------
clear
echo "***********************"
echo "MoRoKernel Build Script"
echo "***********************"
echo ""
echo ""
echo "(1) S20 - G981B"
echo "(2) S20 Plus - G986B"
echo "(3) S20 Ultra - G988B"
echo ""
echo "(4) All: S20, S20P and S20U"
echo ""
echo "**************************************"
echo ""
read -p "Select an option to compile the kernel " prompt
echo ""

case $prompt in
1)
	VARIANT=x1sxxx
	DEFCONFIG=s20_defconfig
	DEVICE=G981B
	MAIN
	;;
2)
	VARIANT=y2sxxx
	DEFCONFIG=s20p_defconfig
	DEVICE=G986B
	MAIN
	;;
3)
	VARIANT=z3sxxx
	DEFCONFIG=s20u_defconfig
	DEVICE=G988B
	MAIN
	;;
*)
	echo "Unknown option: $prompt"
	exit 1
	;;
esac

