#!/bin/sh

ARCH=$(arch)
TARGET=aarch64

echo You are running this scipt on a $ARCH mechine....

if [ "$ARCH" != "$TARGET" ];then
sudo apt-get install qemu-user-static
else
echo "You are running this script on a aarch64 mechine, progress...."
fi

# 判断主机架构，从而判断是否需要安装qemu

ROOTFS=root
SOFTADDR=http://mirrors.tuna.tsinghua.edu.cn/debian

sudo apt install debootstrap debian-keyring
mkdir $ROOTFS
sudo debootstrap --arch=arm64 buster ./$ROOTFS $SOFTADDR

if [ "$ARCH" != "$TARGET" ];then
sudo cp /usr/bin/qemu-aarch64-static $ROOTFS/usr/bin
else
echo "You are running this script on a aarch64 mechine, progress...."
fi

# 判断主机架构，从而判断是否需要qemu来进行chroot

chroot $ROOTFS apt-get install -y sudo ssh net-tools ethtool wireless-tools network-manager iputils-ping rsyslog alsa-utils bash-completion gnupg busybox kmod --no-install-recommends

# 使用chroot来安装所需软件包

cat <<EOF | chroot $ROOTFS adduser pi && addgroup pi adm && addgroup pi sudo && addgroup pi audio
raspberry
raspberry
pi
0
0
0
0
y
EOF

# 创建用户
# 用户名：pi
# 密码：raspberry

chroot $ROOTFS dpkg --add-architecture armhf
chroot $ROOTFS apt-get install libc6:armhf

# 开启32位兼容

chroot $ROOTFS apt clean
# 清除软件安装包缓存

if [ "$ARCH" != "$TARGET" ];then
sudo rm $ROOTFS/usr/bin/qemu-aarch64-static
else
echo "You are running this script on a aarch64 mechine, progress...."
fi

# 我真的不想说这是干嘛的了

echo '127.0.0.1	raspberrypi' >> $ROOTFS/etc/hosts

# 编辑hosts

cat /dev/null > $ROOTFS/etc/hostname
echo 'raspberrypi' >> $ROOTFS/etc/hostname

# 一遍是你构建使用的主机的hostname，看情况自行修改

cp files/010_pi-nopassword etc/sudoers.d

# 用户pi免密码执行root命令

mkdir kernel
mkdir tmp

wget -O kernel/firmware-bin.deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/pool/main/r/raspberrypi-firmware/libraspberrypi-bin_1.20190925-2_armhf.deb
echo 'Installing to root ....'
sudo dpkg -x kernel/firmware-bin.deb tmp
cp -rfp tmp/* $ROOTFS
rm -rf tmp/*

wget -O kernel/firmware-dev.deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/pool/main/r/raspberrypi-firmware/libraspberrypi-dev_1.20190925-2_armhf.deb
echo 'Installing to root ....'
sudo dpkg -x kernel/firmware-dev.deb tmp
cp -rfp tmp/* $ROOTFS
rm -rf tmp/*

wget -O kernel/libraspberrypi0.deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/pool/main/r/raspberrypi-firmware/libraspberrypi0_1.20190925-2_armhf.deb
echo 'Installing to root ....'
sudo dpkg -x kernel/libraspberrypi0.deb tmp
cp -rfp tmp/lib/* $ROOTFS/lib
rm -rf tmp/lib
cp -rfp tmp/* $ROOTFS
rm -rf tmp/*

wget -O kernel/bootloader.deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/pool/main/r/raspberrypi-firmware/raspberrypi-bootloader_1.20190925-2_armhf.deb
echo 'Installing to root ....'
sudo dpkg -x kernel/bootloader.deb tmp
cp -rfp tmp/* $ROOTFS
rm -rf tmp/*

wget -O kernel/kernel.deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/pool/main/r/raspberrypi-firmware/raspberrypi-kernel_1.20190925-2_armhf.deb
echo 'Installing to root ....'
sudo dpkg -x kernel/kernel.deb tmp
cp -rfp tmp/lib/* $ROOTFS/lib
rm -rf tmp/lib
cp -rfp tmp/* $ROOTFS
rm -rf tmp/*

# 获取树莓派官方提供的bootloader，kernel，内核设备树等

mkdir kernel-headers

wget -O kernel-headers/headers.deb https://mirrors.tuna.tsinghua.edu.cn/raspberrypi/pool/main/r/raspberrypi-firmware/raspberrypi-kernel-headers_1.20190925-2_armhf.deb
echo 'Installing to root ....'
sudo dpkg -x kernel-headers/headers.deb tmp
cp -rfp tmp/lib/* $ROOTFS/lib
rm -rf tmp/lib
cp -rfp tmp/* $ROOTFS
rm -rf tmp/*

# 获取内核头文件，方便后期编译模块

rm -rf $ROOTFS/lib/modules/*7+
rm -rf $ROOTFS/lib/modules/*7l+
rm -rf kernel
rm -rf kernel-headers
rm $ROOTFS/boot/kernel.img
rm $ROOTFS/boot/kernel7.img
rm $ROOTFS/boot/kernel7l.img
rm -rf tmp

# 删除缓存，无用的32位内核头文件，内核模块，内核

#cp files/cmdline.txt $ROOTFS/boot
#cp files/config.txt $ROOTFS/boot

# 添加开机配置，启动命令
# 使用EFI引导则跳过这一步

#git clone --depth=1 https://github.com/RPi-Distro/firmware-nonfree
#rm -rf firmware-nonfree/.git
#mv firmware-nonfree firmware
#mv firmware $ROOTFS/lib
# 获取一些附带设备的驱动

cat /dev/null > $ROOTFS/etc/fstab

cat <<EOF >> $ROOTFS/etc/fstab
proc            /proc           proc    defaults          0       0
/dev/mmcblk0p2  /boot           ext4    defaults          0       0
/dev/mmcblk0p1  /boot/efi       vfat    defaults          0       2
/dev/mmcblk0p3  /               f2fs    defaults,noatime  0       1
# a swapfile is not a swap partition, no line here
#   use  dphys-swapfile swap[on|off]  for that
tmpfs /tmp tmpfs defaults,noatime,nosuid,size=100m 0 0
tmpfs /var/tmp tmpfs defaults,noatime,nosuid,size=30m 0 0
tmpfs /var/log tmpfs defaults,noatime,nosuid,mode=0755,size=100m 0 0
tmpfs /var/run tmpfs defaults,noatime,nosuid,mode=0755,size=2m 0 0
tmpfs /var/spool/mqueue tmpfs defaults,noatime,nosuid,mode=0700,gid=12,size=30m 0 0
EOF

# 编辑分区信息
