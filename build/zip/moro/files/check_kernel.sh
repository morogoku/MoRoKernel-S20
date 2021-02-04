#!/system/bin/sh
# 
# Check MoRoKernel
# by morogoku
#

mount -t rootfs -o rw,remount rootfs;
#mount -o rw,remount /system;
mount -o rw,remount /data;
mount -o rw,remount /;


# RC files dir
RCDIR=/system/etc/init/hw


# Clean init.rc
sed -i '/init.ts.rc/d' $RCDIR/init.rc
sed -i '/init.custom.rc/d' $RCDIR/init.rc
sed -i '/init.services.rc/d' $RCDIR/init.rc
sed -i '/init.spectrum.rc/d' $RCDIR/init.rc


# If no MoroKernel installed, remove files
if ! grep -q MoRoKernel /proc/version; then 
    # Remove rc files
    rm -f $RCDIR/init.moro.rc
    sed -i '/init.moro.rc/d' $RCDIR/init.rc
    
    rm -Rf /data/.morokernel
fi


#Unmount
mount -t rootfs -o ro,remount rootfs;
#mount -o ro,remount /system;
mount -o rw,remount /data;
mount -o ro,remount /;
