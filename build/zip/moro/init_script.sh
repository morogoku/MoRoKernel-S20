#!/sbin/sh
#
# MoRoKernel SAR init script
#
#


# Scripts dir
SDIR=/data/.morokernel/scripts
mkdir -p $SDIR

# RC files dir
RCDIR=/system_root/system/etc/init/hw


# Clean init.rc
sed -i '/init.moro.rc/d' $RCDIR/init.rc
sed -i '/init.ts.rc/d' $RCDIR/init.rc
sed -i '/init.custom.rc/d' $RCDIR/init.rc
sed -i '/init.services.rc/d' $RCDIR/init.rc
sed -i '/init.spectrum.rc/d' $RCDIR/init.rc

# Copy kernel files
cp -f /tmp/moro/files/check_kernel.sh $SDIR
cp -f /tmp/moro/files/moro_init.sh $SDIR
cp -f /tmp/moro/files/init_d.sh $SDIR
cp -f /tmp/moro/files/install_apk.sh $SDIR
cp -f /tmp/moro/files/init.moro.rc $RCDIR
chmod 755 /data/.morokernel/scripts/*
chmod 755 $RCDIR/init.moro.rc


line=$(grep -n 'import' $RCDIR/init.rc | cut -d: -f 1 | tail -n1);

# Add import init.moro.rc to init.rc
sed -i ''${line}'a\import \/system\/etc\/init\/hw\/init.moro.rc' $RCDIR/init.rc


