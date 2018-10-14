---
layout: post
title:  "Use QEMU to Play with Linux Kernel"
date:   2018-09-11
published: true
categories: kernel_others
---

## Command summary

```bash
qemu-img create -f qcow2 [NAME] 10G

qemu-system-x86_64 -cdrom ~/PATH/DISTRO_ISO.iso -boot order=d -drive \
                file=[NAME],format=qcow2 -m 2G

qemu-system-x86_64 -enable-kvm -net nic -net user,hostfwd=tcp::2222-:22,smb=$PWD/ \
                   -daemonize -m 4G -smp cores=4,cpus=4 [NAME]
```

**Info:**
If you find any problem with this tutorial, please let me know. I will be glad
to fix it.
{: .notice_info}

## Introduction

If you are curious about Linux Kernel development, but you feel afraid of
accidentally break your system due to your experiments, the answer for your
problems can be summarize in one technology: Virtual Machine (VM). In this
tutorial, we will examine how to use QEMU, which is an extremely powerful
hardware virtualization tool that can be used in many different contexts. I
particularly appreciate QEMU because it is a very popular tool (as a result, it
is easy to find information about it in the Internet), it receives constant
updates, it is a feature rich machine emulation, it is free software, and it
was originally designed for development.

QEMU is a generic machine emulator based on dynamic translation [3] that can
operate in two different modes [2]:

* **Full system emulation**: A mode that completely emulates a computer. It
  can be used to launch different Operating Systems (OS);
* **User mode emulation**: Enables to launch a process for one sort of CPU on
  another CPU.

If you have recent `x86` machine, you can use QEMU with KVM and achieve high
performance.

## Prerequisites: Install QEMU and KVM

To follow this tutorial you need to install QEMU and Samba Client (for sharing
between your host and guest).

### Arch Linux

Install Arch Linux packages [1]:

```bash
sudo pacman -S qemu samba qemu-arch-extra
```

### Debian

Install Debian packages [2]:

```bash
sudo apt install qemu samba samba-client
```

## Create an image

We want QEMU running a Linux Distribution for our future experiments with
Linux. With this goal in mind, we have to create an image disk with the
following command:

```bash
qemu-img create -f qcow2 kernel_experiments 15G
```
**Attention:**
Do not copy and paste the command above or any other find in this tutorial, try
to understand it first.
{: .notice_warning}


* `qemu-img`: It is the disk image utility provided by QEMU;
  * `create`: Indicate that we want to create new QEMU disk image;
  * `-f format`: Specifies the image format; usually, you want 'raw' or
    'qcow2'. Raw images are fast, but it uses all the determined size at once;
    on the other hand, qcow2 is a little bit slower, but it increases the image
    size based on the VM usage;
  * `filename`: The create command expects a filename for the new image. Here,
    we decided by kernel_experiments;
  * `size`: The image size, we decided by 15G.

For this tutorial, I recommend you to use qcow2 with 10 or 15G.

## Installing an Distro

Next, download the Linux Distribution that you want to use (I always recommend
Debian or ArchLinux). With your QEMU image and your distro ISO, proceed with
the command below (remember to adapt it):

```bash
qemu-system-x86_64 -cdrom ~/PATH/TO/YOUR_DISTRO_ISO.iso -boot order=d -drive \
                   file=kernel_experiments,format=qcow2 -m 2G
```

**Notice:**
For simplicity sake, create a user in the VM that match with your host machine
user.
{: .notice_warning}

Proceed with the installation, and come back here after you finish.

## Start QEMU

Finally, it is time to start the machine. Take a look at the command below and
adapt it for your needs:

```bash
qemu-system-x86_64 -enable-kvm -net nic -net user,hostfwd=tcp::2222-:22,smb=$PWD/ \
                   -daemonize -m 2G -smp cores=4,cpus=4 kernel_experiments
```

* `qemu-system-x86_64`: Command that start the QEMU VM.
  * `-enable-kvm`: Enable full virtualization by using KVM [5];
  * `-net`: Network options;
  * `-daemonize`: Daemonize the QEMU process after initialization;
  * `-m`: RAM size;
  * `-smp`: Simulate a SMP system with n CPUs.

For a detailed information about the above options take a look at the man page.

**Notice:**
In some distros, the command above fails or show a warning due to the
`-enable-kvm` parameter. Probably, your username is not a part of the KVM
group. You can fix it by adding yourself to the KVM group. For example:
`sudo usermod -a -G kvm username`
{: .notice_warning}

## Configure ssh

**Info:**
You have a vast number of options for setting up your SSH; we provide a 1000
foot view of the process.
{: .notice_info}

To improve your experience with VM, it is a good idea to set up the ssh. First,
you need to create a key pair on your machine (if you do not have it yet) with
the command:

```
ssh-keygen -t rsa
```

We will not discuss details about this processes here because you can easily
find information about this configuration on the Internet [4]. After the key
set up, you need to prepare your VM to accept ssh connection. Just install the
package `openssh` (Arch: openssh, Debian: openssh-server).

Subsequently a fresh installation, you will need to temporally enable password
authentication in your VM in order to get into the VM from your host machine.
Follow the steps below:

1. In your VM:  `sudo vim /etc/ssh/sshd_config`;
2. Search for `PasswordAuthentication`, enable it by uncomment (just delete the
  `#` in front of the option) and set it to `yes`;
3. Restart the service: `sudo systemctl restart sshd`.

Now, from your host machine test the login in the VM with:

```
ssh -p 2222 127.0.0.1
```

If everything works as expected, at this point, you can access the VM from your
host machine. Go out of the VM, and from your host machine type:

```
ssh-copy-id -p 2222 user@127.0.0.1
```

Try to reaccess the VM, open the file `sshd_config`, comment the line with
`PasswordAuthentication`, restart the `sshd` service, and leave the VM.
Finally, try to ssh into the VM, and you will be able to access the machine
using your ssh key.

## Conclusion

Keep in mind that we just scratch the QEMU surface, this tool provides a lot of
features and have other tools to make easy the management of VMs. Finally,
follow the feed for new tutorials about QEMU and Linux development.

## History

1. V1: Release

## References

1. [QEMU Arch Linux](https://wiki.archlinux.org/index.php/QEMU)
2. [QEMU Debian](https://wiki.debian.org/QEMU#Installation)
3. [QEMU](https://www.qemu.org/)
4. [Set up SSH key](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
5. [KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine)
