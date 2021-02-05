#!/sbin/sh
#
# MoRoKernel init functions
#


# Functions
ui_print() { echo -n -e "ui_print $1\n"; }


file_getprop() { grep "^$2" "$1" | cut -d= -f2; }


show_progress() { echo "progress $1 $2"; }


set_progress() { echo "set_progress $1"; }


set_perm() {
    chown $1.$2 $4
    chown $1:$2 $4
    chmod $3 $4
    chcon $5 $4
}


clean_magisk() {
    rm -rf /cache/*magisk* /cache/unblock /data/*magisk* /data/cache/*magisk* /data/property/*magisk* \
    /data/Magisk.apk /data/busybox /data/custom_ramdisk_patch.sh /data/app/com.topjohnwu.magisk* \
    /data/user*/*/magisk.db /data/user*/*/com.topjohnwu.magisk /data/user*/*/.tmp.magisk.config \
    /data/adb/*magisk* /data/adb/post-fs-data.d /data/adb/service.d /data/adb/modules* 2>/dev/null
}


abort() {
    ui_print "$*";
    echo "abort=1" > /tmp/aroma/abort.prop
    exit 1;
}

init_variables() {
    BB=/tmp/moro/busybox
    BL=`getprop ro.bootloader`
    DEVICE=${BL:0:5}
}

