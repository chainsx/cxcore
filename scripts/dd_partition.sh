#!/bin/sh
LOOPIMGF=$(ls /dev | grep loop0)
LOOPIMGS=$(ls /dev | grep loop1)
LOOPIMGT=$(ls /dev | grep loop2)
ROOTFSPAT=mmcblk0p3
BOOTIMG=boot.img
KERNELIMG=kernelpat.img
IMGNAME=debian.img

losetup --offset=1048576 --sizelimit=269484032 $LOOPIMGF debian.img
losetup --offset=269484544 --sizelimit=336593408 $LOOPIMGS debian.img
losetup --offset=336593920 --sizelimit=2284845568 $LOOPIMGT debian.img

# 映射虚拟文件系统

mkfs.f2fs -l ROOTFS /dev/$LOOPIMGT

mkdir $ROOTFSPAT

mount /dev/$LOOPIMGT $ROOTFSPAT

cp -rfp p3/* $ROOTFSPAT

sync

umount /dev/$LOOPIMGT

dd if=$BOOTIMG of=/dev/$LOOPIMGF
dd if=$KERNELIMG of=/dev/$LOOPIMGS

sync

losetup --detach /dev/$LOOPIMGT
losetup --detach /dev/$LOOPIMGF
losetup --detach /dev/$LOOPIMGS

# 删除映射

parted -s $IMGNAME -- toggle 1 lba
parted -s $IMGNAME -- toggle 1 boot

# 使树莓派能够识别启动
