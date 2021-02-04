#!/sbin/sh
#
# MoRoKernel Flash script
#
# 


# Initialice Morokernel folder
if [ ! -d /data/.morokernel/apk ]; then
    mkdir -p -m 777 /data/.morokernel/apk 2>/dev/null
fi


# Load functions
. /tmp/moro/functions.sh


#======================================
# AROMA INIT
#======================================

set_progress 0.01

# Mount
ui_print "@Mount partitions"
ui_print "-- mount /system"
mount /system


# Init variables 
init_variables


set_progress 0.10
show_progress 0.25 -6000


## INIT SCRIPT
ui_print " "
ui_print "@Copying files"
ui_print "-- Add init script"
. /tmp/moro/init_script.sh


set_progress 0.35
show_progress 0.25 -24000


## FLASH KERNEL
ui_print " "
ui_print "@Flashing kernel"

cd /tmp/moro
ui_print "-- Extracting"
$BB tar -Jxf kernel.tar.xz $DEVICE-boot.img
if [ ! -e /tmp/moro/$DEVICE-boot.img ]; then
	ui_print " "
	ui_print "@** KERNEL NOT FOUND **"
	abort "-- Aborting..."
fi


# Write kernel img
ui_print "-- Flashing kernel $DEVICE-boot.img"
dd of=/dev/block/platform/13100000.ufs/by-name/boot if=/tmp/moro/$DEVICE-boot.img
ui_print "-- Done"


set_progress 0.60

#======================================
# OPTIONS
#======================================


## MTWEAKS
if [ "$(file_getprop /tmp/aroma/menu.prop chk3)" == 1 ]; then
	ui_print " "
	ui_print "@MTWeaks App"
	sh /tmp/moro/moro_clean.sh com.moro.mtweaks -as
	cp -rf /tmp/moro/mtweaks/*.apk /data/.morokernel/apk
fi


set_progress 0.65


#======================================
# ROOT
#======================================


ui_print " "
ui_print "@Root"
	
## MAGISK ROOT
if [ "$(file_getprop /tmp/aroma/menu.prop chk2)" == 1 ]; then
show_progress 0.34 -19000

	if [ "$(file_getprop /tmp/aroma/menu.prop chk7)" == 1 ]; then
		ui_print "-- Clearing root data"
		clean_magisk
		sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd
	fi

	ui_print "-- Rooting with Magisk Manager"
	ui_print " "
	$BB unzip /tmp/moro/magisk/magisk.zip META-INF/com/google/android/* -d /tmp/moro/magisk
	sh /tmp/moro/magisk/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/magisk/magisk.zip
	cp /tmp/moro/magisk/magisk.zip /data/adb/magisk/magisk.apk

else

## WITHOUT ROOT
show_progress 0.34 -5000

	ui_print "-- Without Root"
	if [ "$(file_getprop /tmp/aroma/menu.prop chk7)" == 1 ]; then
		ui_print "-- Clear root data"
		clean_magisk
		sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd
	fi
fi


# Unmount
ui_print "@Unmount partitions"
ui_print "-- umount /system"
umount /system

rm -fR /tmp/moro

set_progress 1.00


