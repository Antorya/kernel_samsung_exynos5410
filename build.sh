#!/bin/bash
#  #####  ###### ###### #####  ######  ##  ##  ##### 
# ##   ## ##   ##  ##  ##   ## ##   ## ##  ## ##   ##
# ##   ## ##   ##  ##  ##   ## ##   ## ##  ## ##   ##
# ####### ##   ##  ##  ##   ## ######   ####  #######
# ##   ## ##   ##  ##  ##   ## ##   ##   ##   ##   ##
# ##   ## ##   ##  ##  ##   ## ##   ##   ##   ##   ##
# ##   ## ##   ##  ##   #####  ##   ##   ##   ##   ##
# Telegram:Livet|Github:fatihunsever

BUILDVER=STABLE
CPU=`grep -c ^processor /proc/cpuinfo`
DIR=`readlink -f .`

echo ""; ccache -cs; echo ""; arm-linux-gnueabi-gcc --version

echo "e.q.: |0.1|-|2.3|-|4.5|"
echo -ne "Ver.Num.: "; read NUM
echo "$NUM" > .version; echo ""

find $DIR -name '*.log' -exec rm -rf {} \;
find $DIR -name "*.ko" -exec rm -rf {} \;

BUILDLOS() {
make mrproper; git checkout lineage
if [ -f defconfig ]; then
  cp defconfig .config
  make -j$CPU
else
  echo "defconfig file not found!"
fi
}

BUILDTW() {
make mrproper; git checkout touchwiz
if [ -f defconfig ]; then
  cp defconfig .config
  make -j$CPU
else
  echo "defconfig file not found!"
fi
}

TWMODULES=~/Desktop/TW-MODULES
IMAGES=~/Desktop/IMAGES

find $IMAGES/ -name "*zImage*" -exec rm -rf {} \;

( echo "--LOS zImage--"; BUILDLOS ) 2>&1 | tee -a kernel.log;
if [ -f arch/arm/boot/zImage ]; then
  mv arch/arm/boot/zImage $IMAGES/zImage-LOS-$BUILDVER-$NUM
    if [ -f $IMAGES/zImage-LOS-$BUILDVER-$NUM ]; then
      make mrproper
    fi;
else
  echo "LOS zImage not found! Fix errors and restart this script."; return 0
fi;

( echo "--TW zImage--"; BUILDTW ) 2>&1 | tee -a kernel.log;
if [ -f arch/arm/boot/zImage ]; then
  mv arch/arm/boot/zImage $IMAGES/zImage-TW-$BUILDVER-$NUM
   find $TWMODULES/ -name "*.ko" -exec rm -rf {} \;
   find $DIR -name "*.ko" -exec mv {} $TWMODULES/ \;
   arm-linux-gnueabi-strip --strip-unneeded $TWMODULES/*.ko
    if [ -f $IMAGES/zImage-TW-$BUILDVER-$NUM ]; then
      make mrproper
    fi;
else
  echo "TW zImage not found! Fix errors and restart this script."; return 0
fi
