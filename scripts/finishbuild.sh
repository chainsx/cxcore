#!/bin/sh

IMAGE=debian.img
IMAGEBLOCK=/dev/mapper/loop0p
BOOTPATH=root/boot
TARGETBOOT=tmp/firstblock

kpartx -av $IMAGE

mkdir tmp
mkdir tmp/firstblock
mkdir tmp/secondblock
mkdir tmp/thirdblock

mount $IMAGEBLOCK'1' tmp/firstblock
mount $IMAGEBLOCK'2' tmp/secondblock
mount $IMAGEBLOCK'3' tmp/thirdblock

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

echo "finish"