# 树莓派64位PIXEL桌面

![image1](https://raw.githubusercontent.com/chainsx/PIXEL64-RPI/master/img/2020020512003372.png)

#### 我们已经公开了我们所编译的64位软件包，[地址](https://github.com/chainsx/PIXEL64-RPI)

### 使用说明：

添加软件源：https://chainsx.github.io/PIXEL64-RPI

 ```
 apt-get install gnupg wget -y
wget https://chainsx.github.io/PIXEL64-RPI/pub.key
gpg --import pub.key
gpg --export --armor | apt-key add -
rm pub.key
touch /etc/apt/sources.list.d/chainsx.list
echo "deb https://chainsx.github.io/PIXEL64-RPI/ ./" >> /etc/apt/sources.list.d/chainsx.list
echo "Done."
apt-get update
apt-get install xinit --no-install-recommends
apt-get install xserver-xorg --no-install-recommends
apt-get install raspberrypi-ui-mods
```

最后删除在/usr/share/X11/目录下的不兼容的配置文件。

[预构建版本](https://raspberrypi.club/367.html)
