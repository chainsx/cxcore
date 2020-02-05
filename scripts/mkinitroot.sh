#!/bin/sh

mkdir initroot

# 目的是为了能够编译一个初始化根目录
# 从而实现文件系统的初始化和扩容
# 使用buildroot来编译

#BRANCH=master
#BRACH=2020.02.x
# 后期可能需要手动切换分支为2020.02.x

#git clone --depth=1 -b BRANCH https://github.com/buildroot/buildroot
cp files/config buildroot/.config
cd buildroot && make
cd ..

cp buildroot/output/images/rootfs.tar initroot
rm -rf buildroot
cd initroot && tar -xvf rootfs.tar
rm rootfs.tar
cd ..

cp files/S99flash initroot/etc/init.d
chmod +x initroot/etc/init.d/S99flash

# 添加开机自动执行脚本

rm initroot/etc/fstab
cp files/init-fstab initroot/etc

# 更新分区信息

mksquashfs initroot recovery.rfs

# 制作squashfs文件

rm -rf initroot

NOOBSADDR=https://mirrors.tuna.tsinghua.edu.cn/raspbian-images/NOOBS_lite/images/NOOBS_lite-2019-07-12/NOOBS_lite_v3_2.zip

mkdir noobs
wget -O noobs/noobs.zip $NOOBSADDR
cd noobs
rm *zip
rm *rfs
rm *txt
cd ..
mv recovery.rfs noobs

# 使用noobs的引导文件来引导所编译的初始化根目录
