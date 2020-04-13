#!/bin/sh

mkdir initroot

# 目的是为了能够编译一个初始化根目录
# 从而实现文件系统的初始化和扩容
# 使用buildroot来编译

sudo apt-get install squashfs-tools
#BRANCH=master
#BRACH=2020.02.x
# 后期可能需要手动切换分支为2020.02.x

#git clone --depth=1 -b BRANCH https://github.com/buildroot/buildroot
#cp files/config buildroot/.config
#cd buildroot && make
#cd ..

#cp buildroot/output/images/rootfs.tar initroot
#rm -rf buildroot
cp files/rootfs.tar.gz initroot
cd initroot && tar -zxvf rootfs.tar.gz
rm rootfs.tar.gz
cd ..

#cp files/S99flash initroot/etc/init.d

cat <<EOF >> initroot/etc/init.d/S99flash
#!/bin/sh
BLKDEV=/dev/mmcblk0
ROOTPART_SEQ=3

dialog --title INIT-SYSTEM --infobox "Initing System, Please Wait A Moment....." 20 60

parted -s $BLKDEV -- resizepart $ROOTPART_SEQ 100%
resize.f2fs $BLKDEV"p"$ROOTPART_SEQ

cd /boot
rm *.dtb >> /dev/null
rm BUILD-DATA >> /dev/null
rm -rf defaults >> /dev/null
rm -rf overlays >> /dev/null
rm recover* >> /dev/null
rm RECOVERY_FILES_DO_NOT_EDIT >> /dev/null
rm riscos-boot.bin >> /dev/null

mv EFI-BOOT/* . >> /dev/null
rmdir EFI-BOOT >> /dev/null

sync

sleep 5
reboot
EOF
chmod +x initroot/etc/init.d/S99flash

# 添加开机自动执行脚本

cat /dev/null > initroot/etc/fstab

cat <<EOF >> initroot/etc
# <file system>	<mount pt>	<type>		<options>	<dump>	<pass>
/dev/root	/		squashfs	rw,noauto	0	1
/dev/mmcblk0p1	/boot		vfat		defaults	0	0
proc		/proc		proc		defaults	0	0
devpts		/dev/pts	devpts		defaults,gid=5,mode=620,ptmxmode=0666	0	0
tmpfs		/dev/shm	tmpfs		mode=0777	0	0
tmpfs		/tmp		tmpfs		mode=1777	0	0
tmpfs		/run		tmpfs		mode=0755,nosuid,nodev	0	0
sysfs		/sys		sysfs		defaults	0	0
EOF

# 更新分区信息

mksquashfs initroot recovery.rfs

# 制作squashfs文件

rm -rf initroot

NOOBSADDR=https://mirrors4.tuna.tsinghua.edu.cn/raspbian-images/NOOBS_lite/images/NOOBS_lite-2019-07-12/NOOBS_lite_v3_2.zip

mkdir noobs
wget -O noobs/noobs.zip $NOOBSADDR
cd noobs
unzip noobs.zip
rm *zip
rm *rfs
rm *txt
cd ..
mv recovery.rfs noobs

# 使用noobs的引导文件来引导所编译的初始化根目录
