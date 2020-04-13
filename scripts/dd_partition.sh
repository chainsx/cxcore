#!/bin/sh
LOOPIMGF=/dev/loop3
LOOPIMGS=/dev/loop1
LOOPIMGT=/dev/loop2
ROOTFSPAT=mmcblk0p3
UEFIPAT=mmcblk0p1
KERNELIMG=kernelpat.img
IMGNAME=debian.img

losetup --offset=1048576 --sizelimit=269484032 $LOOPIMGF debian.img
losetup --offset=269484544 --sizelimit=336593408 $LOOPIMGS debian.img
losetup --offset=336593920 --sizelimit=2284845568 $LOOPIMGT debian.img

# 映射虚拟文件系统

mkfs.f2fs -l ROOTFS $LOOPIMGT
mkfs.vfat -F 32 $LOOPIMGF

mkdir $ROOTFSPAT
mkdir $UEFIPAT

mount $LOOPIMGT $ROOTFSPAT

mount $LOOPIMGF $UEFIPAT

cp -rfp p3/* $ROOTFSPAT
cp -rfp p1/* $UEFIPAT

sync

umount $ROOTFSPAT

umount $UEFIPAT

dd if=$KERNELIMG of=$LOOPIMGS

sync

losetup --detach $LOOPIMGT
losetup --detach $LOOPIMGF
losetup --detach $LOOPIMGS

# 删除映射

parted -s $IMGNAME -- toggle 1 lba
parted -s $IMGNAME -- toggle 1 boot

# 使树莓派能够识别启动
