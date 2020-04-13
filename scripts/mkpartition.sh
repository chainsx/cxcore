#!/bin/sh
#BOOTIMG=boot.img
KERNELIMG=kernelpat.img
#DISKP1=mmcblk0p1
DISKP2=mmcblk0p2

#dd if=/dev/zero of=$BOOTIMG bs=1M count=256 status=progress

dd if=/dev/zero of=$KERNELIMG bs=1M count=64 status=progress

#mkfs.vfat -F 32 $BOOTIMG
#mkfs.ext4 -L KERNEL $KERNELPATSIZE

mkfs.ext4 -L KERNEL kernelpat.img

#mkdir $DISKP1
mkdir $DISKP2

#mount $BOOTIMG $DISKP1
mount $KERNELIMG $DISKP2

#cp -rfp p1/* $DISKP1
cp -rfp p2/* $DISKP2

sync

#umount $DISKP1
umount $DISKP2

sync

#rm -rf $DISKP1
rm -rf $DISKP2
