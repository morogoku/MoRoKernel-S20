#!/sbin/sh
#
# MoRoKernel
# Get device
#


BL=`getprop ro.bootloader`
DEVICE=${BL:0:5}


echo "device=$DEVICE" > /tmp/aroma/device.prop

