#!/bin/bash
#make || exit

PATH=$PATH:../fx2_programmer

DESCR=`fx2_programmer any any dump_busses | grep UNCONFIGURED | head -n 1`
echo "Using device $DESCR"

BUS=`echo "$DESCR" | cut -f 3 -d \  `
DEVICE=`echo "$DESCR" | cut -f 5 -d \  `

#
# put 8051 into reset
#
fx2_programmer $BUS $DEVICE set 0xE600 1
#
# program 8051
#
fx2_programmer $BUS $DEVICE program usbif.ihx
#
# take 8051 out of reset
#
fx2_programmer $BUS $DEVICE set 0xE600 0
#
# dump results of the computation (which is finished by now..)
# 
#fx2_programmer $BUS $DEVICE bulk_dump 0x86 8192 4096
#fx2_programmer $BUS $DEVICE bulk_bench 0x86 102400000 2048
fx2_programmer $BUS $DEVICE play audio.raw
