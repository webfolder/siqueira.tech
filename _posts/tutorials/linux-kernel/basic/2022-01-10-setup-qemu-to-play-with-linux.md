---
layout: post
title:  "Setup QEMU to Play with Linux Kernel"
date:   2022-01-15
categories: "linux-kernel-basic"
author: siqueira
---

{% include add_ref.html id="qemuArch"
    title="QEMU Arch Wiki"
    url="https://wiki.archlinux.org/index.php/QEMU" %}

{% include add_ref.html id="qemuDebian"
    title="QEMU Debian Wiki"
    url="https://wiki.debian.org/QEMU#Installation" %}

{% include add_ref.html id="qemu"
    title="QEMU Official Website"
    url="https://www.qemu.org/" %}

{% include add_ref.html id="sshDo"
    title="How To Set Up SSH Keys"
    date="2012-06-22"
    author="Etel Sverdlov"
    url="https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2" %}

{% include add_ref.html id="kernelVM"
    title="Kernel-based Virtual Machine"
    url="https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine" %}

{% include add_ref.html id="installArch"
    title="Installation guide"
    url="https://wiki.archlinux.org/index.php/installation_guide" %}

{% include add_ref.html id="installArch2"
    title="How to Install Arch Linux [Step by Step Guide]"
    url="https://itsfoss.com/install-arch-linux/" %}

{% include add_ref.html id="nocowFlag"
    title="Disk Images ─ QEMU documentation"
    url="https://qemu.readthedocs.io/en/latest/system/images.html#cmdoption-qcow2-arg-nocow" %}

{% include add_ref.html id="kvmSupport"
    title="KVM Arch Wiki"
    url="https://wiki.archlinux.org/title/KVM#Checking_support_for_KVM" %}

{% include add_ref.html id="kernelParameters"
    title="Kernel parameters Arch Wiki"
    url="https://wiki.archlinux.org/title/Kernel_parameters" %}

{% include add_ref.html id="vmwiki"
    title="Vitual Machine"
    url="https://en.wikipedia.org/wiki/Virtual_machine" %}

{% include add_ref.html id="isawiki"
    title="What is an Instruction Set"
    url="https://en.wikipedia.org/wiki/Instruction_set_architecture" %}

{% include add_ref.html id="sambawiki"
    title="What is SAMBA"
    url="https://en.wikipedia.org/wiki/Samba_(software)" %}


**Disclaim**: Originally, I wrote and published this tutorial on the FLUSP
[FLUSP](https://flusp.ime.usp.br/others/use-qemu-to-play-with-linux/) website.
I decided to republish this material on my website to easily update it and
provide an alternative if the FLUSP website is down.
{: .warning-box}

## Quick Reference

If you did not read this tutorial yet, skip this part. I added this section as
a summary for someone that already read this tutorial and just wants a quick
reference.
{: .info-box}

```bash
qemu-img create -f qcow2 [IMAGE-NAME] 10G

qemu-system-x86_64 -enable-kvm -cdrom ~/PATH/DISTRO_ISO.iso \
  -boot order=d -drive file=[NAME],format=qcow2 -m 2G

qemu-system-x86_64 -enable-kvm \
  -nic user,hostfwd=tcp::2222-:22,smb=/PATH/SHARED/FOLDER \
  -daemonize -m 4G -smp cores=4,cpus=4 [IMAGE-NAME]
```

## Introduction

If you are curious about Linux Kernel development but feel afraid of
accidentally breaking your system due to experiments, there is a simple
solution for you: Virtual Machine (VM) {% include cite.html id="vmwiki" %}. In
this tutorial, we'll learn how to use a powerful hardware virtualization tool
named QEMU. I particularly appreciate QEMU because it's a very popular tool
(thus easy to find information about it on the Internet), it's continuously
updated, it features rich machine emulation, it's free software, and it was
initially designed for developers.

QEMU is a generic machine emulator based on dynamic translation
{% include cite.html id="qemu" %} that can operate in two different modes
{% include cite.html id="qemuDebian" %}:

* **Full system emulation**: A mode that completely emulates a computer. It
  can be used to launch different Operating Systems (OS);
* **User mode emulation**: Enables launching a process for one sort of CPU on
  another CPU.

If you have an `x86` machine, you can use QEMU with KVM and achieve high
performance (search for SVM on AMD and VT on Intel hardware).

For this tutorial, keep in mind that we should avoid working inside the VM as
it is a waste of computational resource. We want to work as much as possible
inside the host and use the VM only for testing our kernel changes; because of
this and for making our work environment comfortable, we need to set up our
QEMU VM to:

* Allow SSH access;
* Share a directory between host and guest.

Figure 1 provides an overview of the workflow we will use to work with the
Linux kernel.

{% include image-post.html
   src="posts/linux_kernel_basic/guest_host.png"
   style="width: 50%"
   caption="Figure 1: Workflow" %}

**Info:**
Please let me know if you find any issues in this tutorial. I will be glad to
fix it.
{: .info}

## Terminology

In this tutorial, we will work inside and outside of a VM. For trying to make
things clear, we will add the following comment on top of each command to
describe better where you need to run it:

* `@VM`: Execute the command inside the VM.
* `@HOST`: Execute the command in your machine.

## Prerequisites: Installing QEMU, KVM and OpenSSH

To follow this tutorial, you need to install QEMU and the Samba Client (samba
is required for sharing directories between your host and guest).

### &rarr; On Arch Linux {% include cite.html id="qemuArch" %}:

```bash
# @HOST
sudo pacman -S qemu qemu-arch-extra samba openssh
```

### &rarr; On Debian {% include cite.html id="qemuDebian" %}:

```bash
# @HOST
sudo apt install qemu samba samba-client openssh
```

## Creating a QEMU Image

We want QEMU running a Linux distribution for our future experiments with
Linux. With this goal in mind, we have to create an image disk with the
following command:

```bash
# @HOST
qemu-img create -f qcow2 [IMAGE-NAME] 15G
```

**Attention:**
Don't blindly copy and paste the command above or any other found in this
tutorial; try to understand it by reading the brief description below the
command and examining the documentation.
{: .warning-box}

* `qemu-img`: It's the disk image utility provided by QEMU;
  * `create`: Indicates that we want to create a new disk image, you can add
    options to enable or disable features;
  * `-f qcow2`: Specifies the image format; usually, you want 'raw' or
    'qcow2'. Raw images are fast, but it uses all the determined size at once;
    on the other hand, qcow2 is a little bit slower, but it increases the image
    size based on VM usage with the limit being the size given at creation;
  * `[IMAGE-NAME]`: This parameter represents the image file name that you want
    to use; feel free to assign whatever name you want to it;
  * `15G`: The image size.

I usually recommend using qcow2 with 10 or 15 GB for working with the Linux
kernel.

**Attention:**
If you use btrfs, look at the troubleshooting section at the end of this post.
{: .warning-box}


Finally, check if everything is fine with the command:

```bash
# @HOST
file [IMAGE-NAME]
```

The output of the command above should be something similar to `[IMAGE-NAME]:
QEMU QCOW Image (v3), 16106127360 bytes`

## Installing a Distro

Next, download any Linux distribution image you want to use (I recommend Debian
or Arch Linux {% include cite.html id="installArch" %}
{% include cite.html id="installArch2" %}). Now that you have a QEMU image file
(created in the previous step) and a distro's ISO, just use the below command:

```bash
# @HOST
qemu-system-x86_64 -enable-kvm \
  -cdrom /PATH/TO/YOUR_DISTRO_ISO.iso -boot order=d \
  -drive file=[IMAGE-NAME] -m 2G
```

Let's briefly dissect the above command:

* `qemu-system-x86_64`: We want to spin up an emulated 64bit system under the x86 instruction set {% include cite.html id="isawiki" %}:
  * `-enable-kvm`: Enable full virtualization by using KVM {% include cite.html id="kernelVM" %};
  * `-cdrom`: This specifies that QEMU should use our emulated cd slot;
  * `-boot order=d`: Specifier we want to boot from CD-ROM first;
  * `-drive`: This defines a new drive on the system (like your usual hard drive) so
  we can just specify our previously create image file by using `-drive file=[NAME]`;
  * `-m`: RAM size; usually we won't need much for installing a system but your milleage may vary
  if you need to compile something (on a Gentoo guest for example).

The above command may fail in some distros or show a warning due to the
`-enable-kvm` parameter. This may happen due to one of the following problems:

* You might not have KVM **support** on your host machine; you likely **do**
  have it if your processor is new (by newer, I mean from 2006), but you might
  want to check it out {% include cite.html id="kvmSupport" %};
* You might not have KVM **enabled** on your machine, which is usually done by
  passing kernel parameters on boot {% include cite.html id="kernelParameters" %};
* Or maybe your host user isn't part of the KVM group. You can fix it by adding
  yourself to the KVM group. For example: `sudo usermod -a -G kvm $USER`.

If you did try out any of the last two options, you should reboot your machine
before using kvm again.

Anyway, proceed with the installation, and come back here after you finish. For
the sake of simplicity, **create a user in the VM that matches with your host
machine user**.

Remember, the above command will start up a VM and use the ISO file you've
downloaded. After installation has finished, you will need to reboot your VM.
{: .success-box}

## Booting up a QEMU VM

Finally, it is time to start the machine. Take a look at the command below and
adapt it for your needs:

```bash
# @HOST
qemu-system-x86_64 -enable-kvm -nic user,hostfwd=tcp::2222-:22,smb=/PATH/TO/YOUR/SHARED/FOLDER -daemonize -m 2G -smp cores=4,cpus=4 [IMAGE-NAME]
```

* `qemu-system-x86_64`: Command that start the QEMU VM.
  * `-nic`: Shortcut to specify network options and hardware options altogether;
    * `user`: Is used to specify user mode network settings (i.e. we shouldn't
      need configuring network on the VM beyond some basics);
    * `hostfwd`: Setup port forwarding so that the host can connect via ssh
      (look QEMU's man pages for more details);
    * `smb`: Here we can specify a folder to be shared using QEMU's internal
      samba-client (we will see more details about it in the sharing directory
      section);
  * `-daemonize`: Daemonize the QEMU process after initialization;
  * `-smp`: Simulate a SMP system with _n_ CPUs.

This command will pop up a window with the recently installed distribution from
the previous step. Look at the man page for more details about the options used
in the above command.

## Configuring SSH

At this point, you can probably login and logout to the VM by typing the VM's
user and password. Using the login VM can be cumbersome for the workflow that
I'm suggesting here, and for this reason we need something more integrated with
the host system.

To make your work experience better, follow the steps below for creating a
passwordless ssh connection, using an RSA key pair.

**Info:**
There're many ways for setting up an SSH connection; here's a 1000 foot view of
the process.
{: .info-box}

First, create an RSA key pair on the host machine (if there isn't any already)
with the command:

**Info:**
If you want to have a fully passwordless setup just enter blank in the below
command.
{: .info-box}

```bash
# @HOST
ssh-keygen -t rsa
```

Explaining the details in the above command is beyond this tutorial. There's
plenty of information about it on the Internet {% include cite.html id="sshDo"%}.
After the key is set up, you need to prepare the recently created VM to accept
ssh connections. Install the package `openssh` on it (Arch: openssh, Debian:
openssh-server).

Since you are working in a fresh installation, you will need to temporarily
enable password authentication in the VM to log in from the host machine.
Follow the steps below:

1. Login in your VM;
2. In the VM: `sudo sed -i 's/#\(PasswordAuthentication\).*/\2 yes/' /etc/ssh/sshd_config`;
3. Restart the service: `sudo systemctl restart sshd`.

Now, from the host machine:

```bash
# @HOST
ssh -p 2222 127.0.0.1
```

Note that the above command will try to log into the VM using the default
host's username, which is `$USER`, so make sure it exists in that machine.
{: .warning-box}

If everything works as expected, at this point, you can access the VM's shell.
Moving on, log out of the VM, and from the host machine, type in the following:

```bash
# @HOST
ssh-copy-id -p 2222 $USER@127.0.0.1
```

Try to reaccess the VM by using `ssh -p 2222 127.0.0.1`. If everything works as
expected, open the file `/etc/ssh/sshd_config` in the VM, comment the line with
`PasswordAuthentication`, restart the `sshd` service, and leave the VM.
Finally, try to ssh into the VM, and you will be able to access the machine
using your ssh key.

## Sharing a Directory With your Local Machine

We are just a few steps away from completing this tutorial and having a fully
functional test environment for playing with the Linux Kernel. Our final goal
is to share a directory between our VM and our host system. We want to share a
directory because we only need to use our VM for testing and not for
development, i.e., we can compile the kernel in our powerful host machine then
install it in the VM. To accomplish this task, we use the sharing mechanism
provided by samba {% include cite.html id="sambawiki" %} (Explain details about
samba is outside this tutorial scope.).

First, we need to install the Samba and CIFS packages in both our systems. Do:

### &rarr; ArchLinux

```bash
# @HOST
sudo pacman -S samba
```

### &rarr; Debian

```bash
# @HOST
sudo apt install samba cifs-utils
```

Second, start your brand new VM and install the same list of packages.

```bash
# @HOST
qemu-system-x86_64 -enable-kvm \
  -nic user,hostfwd=tcp::2222-:22,smb=/PATH/TO/YOUR/SHARED/FOLDER \
  -daemonize -m 2G -smp cores=4,cpus=4 [IMAGE-NAME]

ssh -p 2222 127.0.0.1

# @VM
sudo pacman -S samba cifs-utils
# or
sudo apt install samba cifs-utils
```

Now, we want to set up our VM so that we can share the directory we want
on-demand, i.e., the VM and host start to share a directory if the user tries
to access the folder. We have to create a new SystemD entry to do this. Before
we proceed, it's important to notice that you must replace ``USER``with your
username in the following steps:

1. Let's start by creating a file named `home-USER-shared.mount` (e.g.
   `home-siqueira-shared.mount`) inside `/etc/systemd/system/` under the VM.
   Add the following content (again, replace `USER` in the file):

```
[Unit]
Description=Mount Share at boot
Requires=systemd-networkd.service
After=network-online.target
Wants=network-online.target

[Mount]
What=//10.0.2.4/qemu
Where=/home/USER/shared
Options=vers=3.0,x-systemd.automount,_netdev,x-systemd.device-timeout=10,uid=1000,noperm,credentials=/root/.cifs
Type=cifs
TimeoutSec=30

[Install]
WantedBy=multi-user.target
   ```

   You have to use the correct `uid` here; you can use the command `id YOUR_USER`.
   {: .info-box}

2. Additionally, create another file named `.cifs` under the `/root/` folder
   with the following content:

```
username=YOUR_USER_NAME
password=ANY_PASSWORD_YOU_WANT
```

3. Now, let's update `/etc/fstab`. At the end of `fstab` file add the following
   line:

```
//10.0.2.4/qemu  /PATH/TO/YOUR/SHARED/FOLDER  cifs    uid=1000,credentials=/root/.cifs,x-systemd.automount,noperm 0 0
```

4. Now we create the shared directory:

```bash
# @VM
mkdir shared
```

5. Finally, we have to enable the mount unit configuration file by using:

```bash
# @VM
sudo systemctl enable home-USER-shared.mount
sudo systemctl start home-USER-shared.mount
```

6. Try to access the shared directory created on step 4.

Reboot your VM, start it using the command mentioned early, then access it via
ssh, and try to access the `shared` directory. If everything works well, you
should see the directory and files that you shared with your host machine.

## Conclusion

Keep in mind that we just scratched QEMU's surface; this tool provides many
features and has other mechanisms for efficiently managing VMs. In other words,
we could simplify some of the steps described in this tutorial or even use a
different workflow. Nevertheless, if you are a newcomer, I strongly recommend
you follow each step and read all the references I added since this will help
you build more technical knowledge.

If you are interested in this sort of content, I recommend you follow my feed
since I will post a sequence to this tutorial in a few weeks.

## Acknowledgments

I want to thank Charles Oliveira, Shayenne da Luz Moura, Rodrigo Ribeiro,
Matheus Tavares, Melissa Wen, Isabella Basso, and Marcelo Schmitt for their
reviews and contributions to this tutorial.

{% include print_bib.html %}
