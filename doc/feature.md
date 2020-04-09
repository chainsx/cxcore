#### 这里直接使用了官方编译的64位内核，是由树莓派官方进行调度优化程度最高的内核，因此我们不强调性能。

## 关于UEFI
#### 因为树莓派易用性的特点，本系统在启动方式上选择了UEFI的启动方式，对于这种启动方式，不是单单把编译好的RPI_EFI.fd放在根目录下就掩人耳目地宣称自己支持UEFI，本系统为了树莓派能够发挥易用性的特点，我们通过无数次试验以及对于树莓派本身特性的适配，我们根据UEFI启动的原理，最终实现了UEFI启动，这样，你就能在一个由UEFI启动的系统外又运行其他系统，例如Windows arm，并且在开机时可以用UEFI进行启动系统的选择。

![image2](https://res.raspberrypi.club/wp-content/uploads/2020/01/%E6%89%B9%E6%B3%A8-2020-01-29-164357.png)

#### 我们可以看到使用UEFI时启动命令与传统启动命令的不同

![image3](https://res.raspberrypi.club/wp-content/uploads/2020/02/IMG_20200203_210922.jpg)

#### 是dmesg显示使用64位UEFI

## 关于GRUB：

#### 本系统使用了UEFI，并且引入了grub启动，这样就能实现多系统，而且可以在开机时进行选择，从而替代了像berryboot等使用initrd来在启动时先启动一个轻级系统来进行系统的选择然后根据选择来更改cmdline.txt来启动系统的情况（并没有说berryboot哪里不好，berryboot是一个优秀的开源项目，感谢berryboot的卓越开源贡献）。

## 关于F2FS

#### F2FS (Flash Friendly File System) 是专门为基于 NAND 的存储设备设计的新型开源 flash 文件系统。特别针对NAND 闪存存储介质做了友好设计。F2FS 于2012年12月进入Linux 3.8 内核。F2FS仅支持Linux操作系统。 Nand Flash是存储芯片,而SD卡是将Nand Flash芯片叠加到一起,扩大容量,同时添加管理系统芯片。

看到这里，使用sd卡作为储存设备的树莓派为什么要使用f2fs的原因就不言而喻了吧。

但是由于使用F2FS文件系统之后第一次开机时扩展根目录的速度会很慢。

![image4](https://res.raspberrypi.club/wp-content/uploads/2020/01/%E6%89%B9%E6%B3%A8-2020-01-29-165449.png)

#### 在这里我们可以看到根目录由F2FS文件系统挂载

## 第一次使用时的前置系统：

#### 一般来说，树莓派系统第一次使用时都会进行储存空间的扩容，而很多系统都是直接进入主系统进行扩容操作，然后再重启，本系统使用了noobs的引导程序，基于buildroot自编译了一个用于初始化的前置系统，在前置系统中我们会完成根目录的初始化，例如扩容等操作，都直接一次完成，作为完成这些操作的前置系统划分了一个16M的ramdisk，所以对sd卡的操作是非常安全和有效的。（在此感谢buildroot和noobs的开源精神）

## 使用树莓派官方内核：

这里不做赘述，/proc/cpuinfo是raspi-gpio判断是否为树莓派的根据，而树莓派官方将树莓派整个系列的cpu都在cpuinfo中显示为bcm2835，而cpuinfo最后的cpu型号是非常关键的，树莓派官方内核对于以前64位内核中不显示cpu型号和设备型号的问题进行了补足，保证了64位系统的易用性。我们还内置了有关vc4的组件（官方32位），存放与/opt目录下。（关于这点，官方补足cpuinfo的做法非常给喷子打脸）

![image5](https://res.raspberrypi.club/wp-content/uploads/2020/01/%E6%89%B9%E6%B3%A8-2020-01-29-170517.png)

#### 我们可以看到官方对cpuinfo的补足

*******
