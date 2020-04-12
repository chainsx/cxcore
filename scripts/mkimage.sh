#!/bin/sh

apt-get install f2fs-tools

IMGNAME=debian.img
IMAGECOUNT=2500

dd if=/dev/zero of=$IMGNAME bs=1M count=$IMAGECOUNT status=progress

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
5119999
w
EOF

# 建立分区
# 第一分区（256MB）：EFI引导分区
# 第二分区（64MB）：存放内核
# 第三分区（剩余空间）：根目录

sync
