#!/bin/sh
sh scripts/mkrootfs.sh
#if [ "$(ls | grep rootfs)" != "rootfs" ];then
#echo "Build rootfs success"
#else
#sh scripts/clean.sh
#exit
#fi
sh scripts/mkimage.sh
#if [ "$(ls | grep debian.img)" != "debian.img" ];then
#echo "dd image success"
#else
#sh scripts/clean.sh
#exit
#fi

sh scripts/mkinitroot.sh

#if [ "$(ls | grep noobs)" != "noobs" ];then
#echo "Build initrootfs success"
#else
#sh scripts/clean.sh
#exit
#fi
sh scripts/move_partfile.sh

sh scripts/mkpartition.sh

sh scripts/dd_partition.sh

echo "build image success"
echo "Done"
