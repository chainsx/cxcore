#!/bin/sh

IMAGE=debian.img
IMGBLOCK=/dev/loop
BOOTPATH=root/boot
TARGETBOOT=tmp/firstblock

LOOPIMGF=$(ls /dev | grep loop0)
LOOPIMGS=$(ls /dev | grep loop1)
LOOPIMGT=$(ls /dev | grep loop2)

losetup --offset=1048576 --sizelimit=269484032 $LOOPIMGF debian.img
losetup --offset=269484544 --sizelimit=336593408 $LOOPIMGS debian.img
losetup --offset=336593920 --sizelimit=1572863488 $LOOPIMGT debian.img

mkfs.ext4 -L KERNEL /dev/loop1

mkdir tmp
mkdir tmp/firstblock
mkdir tmp/secondblock
mkdir tmp/thirdblock

mount $IMGBLOCK'0' tmp/firstblock
mount $IMGBLOCK'1' tmp/secondblock
mount $IMGBLOCK'2' tmp/thirdblock

# 挂载loop设备

mkdir tmp/firstblock/EFI-BOOT

mv $BOOTPATH/*dtb $TARGETBOOT/EFI-BOOT
mv $BOOTPATH/*dat $TARGETBOOT/EFI-BOOT
mv $BOOTPATH/*elf $TARGETBOOT/EFI-BOOT
mv $BOOTPATH/bootcode.bin $TARGETBOOT/EFI-BOOT
tar -zxvf files/EFI-boot.tar.gz -C $TARGETBOOT/EFI-BOOT

# 移动EFI启动分区文件

mv noobs/* $TARGETBOOT

# 移动初始化根目录文件

umount $TARGETBOOT

mv $BOOTPATH/kernel8.img tmp/secondblock/vmlinuz
mv $BOOTPATH/overlays tmp/secondblock
mkdir tmp/secondblock/efi
tar -zxvf files/EFI-root.tar.gz -C tmp/secondblock

# 移动ext4分区内核等文件

umount tmp/secondblock

cp -rfp root/* tmp/thirdblock
cp -rfp firmware tmp/thirdblock/lib
rm -rf tmp/thirdblock/lib/firmware/.git

# 移动根目录

umount tmp/thirdblock

sync

losetup --detach /dev/loop0
losetup --detach /dev/loop1
losetup --detach /dev/loop2


echo "finish"
