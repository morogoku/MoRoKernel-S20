#!/bin/bash
#
#
# MoRoKernel Cleaning Script
#


RDIR=$(pwd)
OUTDIR=$RDIR/out


# Clean Build Data
make clean
make ARCH=arm64 distclean

rm -fR $OUTDIR 2>/dev/null
rm -f $RDIR/arch/arm64/configs/tmp_defconfig

rm -f $RDIR/scripts/rkp_cfp/common.pyc
rm -f $RDIR/security/samsung/defex_lsm/defex_packed_rules.bin
rm -f $RDIR/security/samsung/defex_lsm/defex_packed_rules.inc
rm -f $RDIR/security/samsung/defex_lsm/pack_rules

rm -f $OUTDIR/*.log

echo "" > build/ramdisk/ramdisk/debug_ramdisk/.placeholder
echo "" > build/ramdisk/ramdisk/dev/.placeholder
echo "" > build/ramdisk/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/ramdisk/proc/.placeholder
echo "" > build/ramdisk/ramdisk/sys/.placeholder


