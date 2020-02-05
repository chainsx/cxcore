#!/bin/sh
sh scripts/mkrootfs.sh
ROOTCHECK=$(ls | grep root)
ROOTCHECKTARGET=root
if [ "$ROOTCHECK" = "$ROOTCHECKTARGET" ];then
	sh scripts/mkimage.sh
else
	exit
fi
IMGCHECK=$(ls | grep debian.img)
IMGCHECKTARGET=debian.img
if [ "$IMGCHECK" = "$IMGCHECKTARGET" ];then
	sh scripts/mkinitroot.sh
else
	exit
fi
sh scripts/finishbuild.sh