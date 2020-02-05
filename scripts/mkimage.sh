#!/bin/sh

IMGNAME=debian.img
IMAGECOUNT=1500

dd if=/dev/zero of=$IMGNAME.img bs=1M count=$IMAGECOUNT status=progress

# 创建一个1500MB的镜像容器

parted $IMGNAME mktable msdos

# 创建分区表

cat <<EOF | fdisk $IMGNAME
n
p
1
2048
526336
n
p
2
526337
657409
n
p
3
657410
3071999
w
EOF

# 建立分区
# 第一分区（256MB）：EFI引导分区
# 第二分区（64MB）：存放内核
# 第三分区（剩余空间）：根目录

LOOPIMGF=$(ls /dev/mapper/ | grep 1)
LOOPIMGS=$(ls /dev/mapper/ | grep 2)
LOOPIMGT=$(ls /dev/mapper/ | grep 3)

kpartx -av $IMGNAME

# 映射虚拟文件系统

mkfs.vfat -F 32 /dev/mapper/$LOOPIMGF
mkfs.ext4 -L KERNEL /dev/mapper/$LOOPIMGS
mkfs.f2fs -l ROOTFS /dev/mapper/$LOOPIMGT

# 第一分区：vfat文件系统
# 第二分区：ext4文件系统
# 第三分区：f2fs文件系统

sync

kpartx -d $IMGNAME.img

# 删除映射

parted -s $IMGNAME.img -- toggle 1 lba
parted -s $IMGNAME.img -- toggle 1 boot

# 使树莓派能够识别启动
