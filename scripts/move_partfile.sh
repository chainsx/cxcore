#!/bin/sh

BOOTPATH=root/boot
TARGETBOOT=p1
KERNELBLK=p2
ROOTFSBLK=p3

mkdir p1
mkdir p2
mkdir p3

mkdir $TARGETBOOT/EFI-BOOT

mv $BOOTPATH/*dtb $TARGETBOOT/EFI-BOOT
mv $BOOTPATH/*dat $TARGETBOOT/EFI-BOOT
mv $BOOTPATH/*elf $TARGETBOOT/EFI-BOOT
mv $BOOTPATH/bootcode.bin $TARGETBOOT/EFI-BOOT
tar -zxvf files/EFI-boot.tar.gz -C $TARGETBOOT/EFI-BOOT

# 移动EFI启动分区文件

mv noobs/* $TARGETBOOT

# 移动初始化根目录文件

mv $BOOTPATH/kernel8.img $KERNELBLK/vmlinuz
mv $BOOTPATH/overlays $KERNELBLK
mkdir $KERNELBLK/efi
tar -zxvf files/EFI-root.tar.gz -C $KERNELBLK

# 移动根目录文件

cp -rfp root/* $ROOTFSBLK

# 移动根目录

sync