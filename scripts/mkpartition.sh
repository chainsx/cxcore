#!/bin/sh

BOOTIMG=boot.img
KERNELIMG=kernelpat.img
BOOTSIZE=256
KERNELPATSIZE=64
EXTRA=status=progress
DISKP1=mmcblk0p1
DISKP2=mmcblk0p2

dd if=/dev/zero of=$BOOTIMG bs=1M count=$BOOTSIZE $EXTRA
dd if=/dev/zero of=$KERNELIMG bs=1M count=$KERNELPATSIZE $EXTRA

mkfs.vfat -F 32 $BOOTIMG
mkfs.ext4 -L KERNEL $KERNELPATSIZE

mkdir $DISKP1
mkdir $DISKP2

mount $BOOTIMG $DISKP1
mount $KERNELIMG $DISKP2

cp -rfp p1/* $DISKP1
cp -rfp p2/* $DISKP2

sync

umount $DISKP1
umount $DISKP2

sync

rm -rf $DISKP1
rm -rf $DISKP2