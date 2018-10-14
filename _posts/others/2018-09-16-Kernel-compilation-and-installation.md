---
layout: post
title:  "Kernel Compilation and Installation"
date:   2018-09-16
published: true
categories: kernel_others
---

## Command Summary

Follows the command list employed in this tutorial:

`.config` manipulations:

```bash
zcat /proc/config.gz > .config
```
or
```bash
cp /boot/config-`uname -r` .config
```

Change into the `.config` file:

```bash
make nconfig
make olddefconfig
make kvmconfig
make localmodconfig
```

Compile:

```bash
make ARCH=x86_64 -j8
```

Install:

```bash
sudo make modules_install
sudo make headers_install INSTALL_HDR_PATH=/usr
sudo make install
```

Remove:

```bash
rm -rf /boot/vmlinuz-[TARGET]
rm -rf /boot/initrd-[TARGET]
rm -rf /boot/System-map-[TARGET]
rm -rf /boot/config-[TARGET]
rm -rf /lib/modules/[TARGET]
rm -rf /var/lib/initramfs/[TARGET]
```
## Introduction

In this tutorial, we will take a look on how to compile and install the Linux
Kernel inside of Virtual Machine (VM). Nevertheless, 99% of the steps described
in this tutorial are equally valid for a host machine. Finally, we will focus
on Debian and Arch Linux machine.

## Choose your weapon

Nowadays we have multiple options to play around with Linux Kernel. For
simplicity sake, I classify the available approaches into three broad areas:
virtualization, desktop/laptop, and embedded devices. The virtualization
technique is the safer way to conduct experiments with Linux kernel because any
fatal mistake has a few consequences. For example, if you crash the whole
system, you can create another virtual machine or take one of your backups
(yes, make a backup of your VMs). Experiments on the host machine (i.e., your
computer) are more fun, but also riskier. Any potential problem could break all
your system.  Lastly, for the embedded devices, you can make tests in a
developing kit (e.g., raspberry pi). For this tutorial, we decided to use the
virtualization approach.

[//]: <> (TODO: Adicionar o post sobre QEMU no futuro )
[//]: <> (TODO: é bom falar algo assim: "se vc está usando vm, execute os comandos indicados aqui dentro da sua máquina virtual" )

For this tutorial, we decided to use QEMU. If you want to learn how to make the
basic set up with QEMU, I recommend you to read my post about it in "[Use Qemu
to play with Linux Kernel]()". Keep in mind that you can follow the steps
described here in the same fashion on your local machine.

## Get your kernel

The Linux kernel has many subsystems, and most of them keep their Kernel
instance. Usually, the maintainer(s) of each subsystem is responsible for
receiving patches and decide about applying or refuse them. Later, the
maintainer says to Torvalds which branch to merge. This explanation is an
oversimplification of the process; you can find more details in the
documentation [1]. It is important to realize that you have to figure out which
subsystem you intend to contribute, as well as its repository, and work based
on their kernel instance. For example, if you want to contribute to RISC-V
subsystem you have to work on Palmer Dabbelt repository; if you're going to
contribute to IIO use Jonathan Cameron repository. You can quickly figure out
the target branch by looking at the MAINTAINERS file. For this tutorial, we
gonna use the Torvalds repository. 

```bash
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
```

There are thousands of Linux Kernel forks spread around the Internet, for
example, it is easy to find organizations that keep their kernel instance with
their specific customizations. Feel free to use it or any instance that you
want, but keep in mind that you may face some problems with non-official
repositories. I always recommend for newcomers to use the git.kernel.org to get
their Linux code and avoid problems.

## The Super `.config`

The `.config` file holds all the information of what should be compiled or not
during the build process. The `.config` file has three possible answers per
target: (1) m, (2) y, and (3) n. The "m" character means that the target will
be compiled as a module; the 'y' and 'n' designates if the target will be
compiled or not as a part of the Kernel image.

Every Linux Distribution (e.g., Arch, Debian, and Fedora) usually maintain and
distribute their own `.config` file. The distributions `.config` usually
enables most of the available options (especially the device drivers) because
they have to run in a large variety of hardware. In other words, it means that
your computer may have several device drivers which you do not need.
Nonetheless, the important thing here is: the more options you have enabled in
the `.config` file, it takes more time to compile.

If this is your first trying to use your own compiled kernel version, I
strongly recommend you to use the `.config` provided by your operating system
to raise your chances of success. Later, you can expand the modification as we
describe in this tutorial.

**Attention:**
The `.config` file has Superpowers, I recommend you to invest some time to
understand it better. Also, keep a backup of your working `.config` files, you
can save a lot of time by having a trusted `.config`.
{: .notice_danger}

### Get your `.config` file

Depending on the distribution that you use, there are two options to get
`.config` file: `/proc` or `/boot`. Both cases produce the same results, but
not all distributions enable the `/proc` option (e.g., Arch enable it, but
Debian not). The commands below illustrates how to get the `.config` for both
cases:

**Attention:**
Execute this command inside the Linux Kernel directory previously cloned.
{: .notice_danger}

1. Get `.config` from `/proc`

```bash
zcat /proc/config.gz > .config
```

2. Get `.config` from `/boot`

```bash
cp /boot/config-`uname -r` .config
```

### Make your customizations

**Attention:**
There is a basic rule about `.config` file: NEVER CHANGE IT BY HAND, ALWAYS USE
A TOOL
{: .notice_danger}

There are several options to change the `.config`, I introduce two:

```bash
make nconfig
```

`nconfig` looks like this:

{% include image-post.html
  path="posts/nconfig.png"
  caption="nconfig menu"%}

Finally, we have `menuconfig`:

```bash
make menuconfig
```

`menuconfig` looks like this:

{% include image-post.html
  path="posts/menuconfig.png"
  caption="nconfig menu"%}

Navigate to the options and get comfortable with this menu.

### Final considerations about `.config` and tips

**Attention:**
Remember, all the commands explained in the section related to `.config` have
to be executed inside the VM.
{: .notice_danger}

When you use a configuration file provided by a Distribution, hundreds of
device drivers are enabled; typically, you need a few drivers. All the enabled
drivers will raise the compilation time, and you don't want it; fortunately,
there is an option that automatically changes the `.config` to enable only
required drivers for your hardware. Nonetheless, before using commands, it
is highly recommended to enable all the devices that you use with your computer
to ensure that the `.config`  have all the required driver for your machine
activated. In other words, plug all the devices that you usually use before
executing the command:

```bash
make localmodconfig
```

**Remember:**
Before executing the `localmodconfig` target plug-in all the device that you
usually use to get them enabled in the `.config`. However, this plug-in steps
is only required if you are in your host machine; you do not need to care about
this in your VM, just execute the command.
{: .notice_info}

This command uses `lsmod` with the goal to enables or disables devices drivers
in the `.config` file.

[//]: <> (TODO: Tirar um print das perguntas e adicionar aqui)

Sometimes, when you rebase your local branch with the upstream and start the
compilation, you may notice interactive questions regarding new features. This
happens because during the evolution of the Kernel new features are added, and
these new features were not present in your `.config` file. As a result, you
are asked to take a decision. Sometimes, there is a way to reduce the amount of
asked question with the command:

```bash
make olddefconfig
```

Finally, one last tip is related for someone that make experiments in the QEMU
with KVM. There is an option that enables some features for this scenario:

```bash
make kvmconfig
```

## Compile!

Now, it timeeeeee! After a bunch of setup, I am quite sure that you anxious for this part. So, here we go... type:

```bash
make -j [two_times_the_number_of_core]
```

[//]: <> (TODO: Seria legal expandir a explicação do dobro dos cores)
Just replace the `two_times_the_number_of_core` for the number of cores you have by two. For example, if you have 8 cores you should add 16.

As an alternative, you can specify the architecture:

```bash
make ARCH=x86_64 -j [two_times_the_number_of_core]
```

For compiling the kernel modules, type:

```bash
make modules_install
```

## Install your custom kernel

It is important to pay attention in the installation order:

1. Install modules
2. Install header
3. Install Image
4. Update bootloader (Grub)

### Install modules and headers

**Attention:**
From now on, double your attention in the install steps. You can crash your
system.
{: .notice_danger}

Just type:

```bash
sudo make modules_install
```

If you want to check the changes, take a look at `/lib/modules/$(uname -r)`

Finally, install headers:

```bash
sudo make headers_install INSTALL_HDR_PATH=/usr
```

### Debian based steps

Finally, it is time to install your Kernel image. This step does not work on
Arch Linux, see the next section if you are interested in Arch.

To install the Kernel modules just type:

```bash
sudo make install
```

### Arch Linux based steps

If you use Arch Linux, we present the basics steps to install your custom
image. You can find a detailed explanation of this processes in the Arch Linux [wiki](https://wiki.archlinux.org/index.php/Kernels/Traditional_compilation).

First, you have to make a copy of your kernel image to the `/boot/` directory
with the command: 

```bash
sudo cp -v arch/x86_64/boot/bzImage /boot/vmlinuz-[NAME]
```

Replace [NAME] by any name. It could be your name.

Second, you have to create a new `mkinitcpio` file. Follow the steps below:

1. Copy an existing `mkinitcpio`

```bash
sudo cp /etc/mkinitcpio.d/linux.preset /etc/mkinitcpio.d/linux-[NAME].preset
```

2. Open the copied file, look it line by line, replaces the old kernel
name by the name you assigned. See the example:

```
# mkinitcpio preset file for the 'linux' package

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-torvalds"

PRESETS=('default' 'fallback')

#default_config="/etc/mkinitcpio.conf"
default_image="/boot/initramfs-torvalds.img"
#default_options=""

#fallback_config="/etc/mkinitcpio.conf"
fallback_image="/boot/initramfs-torvalds-fallback.img"
fallback_options="-S autodetect"
```

**Attention:**
Keep in mind that you have to adapt this file by yourself. There is no blind
copy and paste here.
{: .notice_danger}

3. Generate the initramfs

```bash
sudo mkinitcpio -p linux-[name].preset
```

### Update Grub2

We are, reallyyyyy close to finishing the process. We have to update the
bootloader, and here we suppose you are using Grub. Type:

```bash
sudo update-grub2
```

Notice, that the command below is a wrapper to the following command:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

So... If the first command fails, try the last one.

Now, reboot your system and check if everything is ok. You should see some options in your Grub as the Figure X illustrates.

{% include image-post.html
  path="posts/grub_vm.png"
  caption="Grub menu options"%}


## Remove

Finally, you may want to remove an old Kernel version for space or organization
reasons. First of all, boot in another version of the Kernel and follow the
steps below:

```bash
rm -rf /boot/vmlinuz-[target]
rm -rf /boot/initrd-[target]
rm -rf /boot/System-map-[target]
rm -rf /boot/config-[target]
rm -rf /lib/modules/[target]
rm -rf /var/lib/initramfs/[target]
```

## References

1. [How the development process works](https://www.kernel.org/doc/html/v4.15/process/2.Process.html)
2. [Install customised kernel in Arch Linux](https://wiki.archlinux.org/index.php/Kernels/Traditional_compilation)
3. [Overview about Initramfs](https://en.wikipedia.org/wiki/Initramfs)
4. [Practical stuffs about Initramfs](http://nairobi-embedded.org/initramfs_tutorial.html)
5. [Great explanation about initramfs](https://landley.net/writing/rootfs-intro.html)
6. [More about initramfs](https://landley.net/writing/rootfs-howto.html)
7. [Nice discussion in Stack Exchange about bzimage in qemu](https://unix.stackexchange.com/questions/48302/running-bzimage-in-qemu-unable-to-mount-root-fs-on-unknown-block0-0)
8. [Kernel Readme](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/tree/README?id=refs/tags/v4.3.3)
9. [Speedup kernel compilation](http://www.h-online.com/open/features/Good-and-quick-kernel-configuration-creation-1403046.html)
10. [Stack Overflow with some tips about speedup kernel compilation](https://stackoverflow.com/questions/23279178/how-to-speed-up-linux-kernel-compilation)
11. [SYSTEMD-BOOT](https://wiki.archlinux.org/index.php/systemd-boot#Adding_boot_entries)
12. [cpio tutorial](https://www.gnu.org/software/cpio/manual/html_mono/cpio.html)
13. [Busybox, build system](https://busybox.net/FAQ.html#build_system)
