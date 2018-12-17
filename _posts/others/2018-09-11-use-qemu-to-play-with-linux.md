---
layout: post
title:  "Use QEMU to Play with Linux Kernel"
date:   2018-09-11
published: true
categories: kernel_others
---

## Command Summary

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

If you are curious about Linux Kernel development but feel afraid of
accidentally breaking your system due to experiments, the solution for such
problems can be summarized in one technology: Virtual Machine (VM). In this
tutorial, we’ll examine how to use QEMU, which is an extremely powerful
hardware virtualization tool that can be used in many different contexts. I
particularly appreciate QEMU because it’s a very popular tool (thus easy to
find information about it on the Internet), it’s continuously updated, it
features rich machine emulation, it’s free software, and it was initially
designed for development.

QEMU is a generic machine emulator based on dynamic translation [3] that can
operate in two different modes [2]:

* **Full system emulation**: A mode that completely emulates a computer. It
  can be used to launch different Operating Systems (OS);
* **User mode emulation**: Enables launching a process for one sort of CPU on
  another CPU.

If you have an `x86` machine, you can use QEMU with KVM and achieve high
performance.

Keep in mind that we should avoid working inside the VM because it is a waste
of computational resource. We want to work as much as possible inside the host
and use the VM only for testing; because of this and for making our work
environment comfortable, we need:

* SSH access;
* Share a directory between host and guest.

Finally, take a careful look at Figure 1 in order to get an overview of the
adopted workflow for this tutorial.

{% include image-post.html
  path="posts/kernel_others/guest_host.png"
  caption="Figure 1: Workflow" %}


## Prerequisites: Installing QEMU and KVM

To follow this tutorial you need to install QEMU and Samba Client (samba is
required for sharing directories between your host and guest).

### &rarr; On Arch Linux [1]:

```bash
sudo pacman -S qemu samba qemu-arch-extra
```

### &rarr; On Debian [2]:

```bash
sudo apt install qemu samba samba-client
```

## Creating an Image

We want QEMU running a Linux distribution for our future experiments with
Linux. With this goal in mind, we have to create an image disk with the
following command:

```bash
qemu-img create -f qcow2 kernel_experiments 15G
```
**Attention:**
Don’t blindly copy and paste the command above or any other found in this
tutorial, try to understand it, by reading the brief description below the
command and examining the documentation.
{: .notice_warning}


* `qemu-img`: It's the disk image utility provided by QEMU;
  * `create`: Indicates that we want to create new disk image, you can add options to enable or disable features;
  * `-f qcow2`: Specifies the image format; usually, you want 'raw' or
    'qcow2'. Raw images are fast, but it uses all the determined size at once;
    on the other hand, qcow2 is a little bit slower, but it increases the image
    size based on VM usage;
  * `kernel_experiments`: This command will end up with an image file, and here is the name that we assign; feel free to change it;
  * `15G`: The image size.

In this tutorial, I recommend using qcow2 with 10 or 15G.

Finally, check if everything is fine by with the command:

```bash
file kernel_experiments
```

The output of the command above, should be something similar to `kernel_experiments: QEMU QCOW Image (v3), 16106127360 bytes`

## Installing a Distro

Next, download any Linux distribution image you want to use (I recommend Debian
or ArchLinux[6,7], but it can be any). With your QEMU image file created above
and your distro's ISO, follow the command below:

```bash
qemu-system-x86_64 -cdrom ~/PATH/TO/YOUR_DISTRO_ISO.iso -boot order=d -drive \
                   file=kernel_experiments,format=qcow2 -m 2G
```

**Notice:**
The command above will start up a VM and mount the ISO file you've downloaded
on it. After installation has finished, it'll reboot the VM automatically.
{: .notice_warning}

Proceed with the installation, and come back here after you finish. For the
sake of simplicity, **create a user in the VM that match with your host machine
user**.

## Booting up a QEMU VM

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

This command will pop up a window with the recently installed distribution from
the step before. For detailed information about the options used in this
command, take a look at the man page.

**Notice:**
In some distros, the above command fails or show a warning due to the
`-enable-kvm` parameter. Probably, your host user isn't part of the KVM
group. You can fix it by adding yourself to the KVM group. For example:
`sudo usermod -a -G kvm $USER`
{: .notice_warning}

## Configuring SSH

At this point, probably you can log in and out of the VM by typing the VM's
user's password; this can be cumbersome during the work. To make your work
experience better follows the steps below for creating a passwordless ssh
connection, using an RSA key pair.

**Info:**
There're many ways for setting up an SSH connection; here's a 1000 foot view of
the process.
{: .notice_info}

First, create an RSA key pair on the host machine (if there isn't any already)
with the command:

```
ssh-keygen -t rsa
```

Explaining the above command is beyond this tutorial. There's plenty of
information about it on the Internet [4]. After the key is set up, you need to
prepare the recently created VM to accept ssh connections. Just install the
package `openssh` on it (Arch: openssh, Debian: openssh-server).

Since you are working in a fresh installation, you will need to temporally
enable password authentication in the VM in order to log in from the host
machine. Follow the steps below:

1. In the VM: `sudo sed -i 's/#.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config`;
2. Restart the service: `sudo systemctl restart sshd`.

Now, from the host machine test logging in into the VM with:

```
ssh -p 2222 127.0.0.1
```

**Notice**
Note that the above command will try to log into the VM using the default
host's username, which is $USER.
{: .notice_warning}

If everything works as expected, at this point, you can access the VM's shell.
Moving on, log out of the VM, and from the host machine type the following:

```
ssh-copy-id -p 2222 $USER@127.0.0.1
```

Try to reaccess the VM, open the file `/etc/ssh/sshd_config`, comment the line
with `PasswordAuthentication`, restart the `sshd` service, and leave the VM.
Finally, try to ssh into the VM, and you will be able to access the machine
using your ssh key.

## Sharing a Directory With your Local Machine

We are close of having a great development environment for playing with Linux
Kernel; we just have to set up a final detail: share a directory between our VM
and our host system. We want to share a directory because we only need to use
our VM for testing and not for developing; i.e., we compile the kernel in our
powerful host machine and install the final binaries in the VM. To accomplish
this task, we use a share mechanism provided by samba.

First, we need to install the samba and cisfs package in the system. Try:

### &rarr; ArchLinux
```
sudo pacman -S samba cifs-utils
```

### &rarr; Debian
```
sudo apt install samba cifs-utils
```

Second, start the VM and install the same packages.


```
$ qemu-system-x86_64 -enable-kvm -net nic -net user,hostfwd=tcp::2222-:22,smb=$PWD/ \
                   -daemonize -m 2G -smp cores=4,cpus=4 kernel_experiments

$ ssh -p 2222 127.0.0.1

[inside_vm] $ sudo pacman -S samba cifs-utils
```
Now, we want to make an automatic setup in our VM that make the directory
shareable on-demand, i.e., the VM and host start to share a directory if the
user tries to access the folder. For doing it, we have to create a new
`systemctl` entry. In your VM create the file `home-shared.mount` inside
`/etc/systemd/system/`, with the following content:

```
[Unit]
Description=Mount Share at boot
Requires=systemd-networkd.service
After=network-online.target
Wants=network-online.target

[Mount]
What=//10.0.2.4/qemu
Where=/home/{{ user }}/shared
Options=x-systemd.automount,_netdev,x-systemd.device-timeout=10,uid=1000,noperm,credentials=/root/.cifs
Type=cifs
TimeoutSec=30

[Install]
WantedBy=multi-user.target
```

Additionally, create another file named `.cifs` in `/root/` with the following
content:

```
username=YOUR_USER_NAME
password=ANY_PASSWORD_YOU_WANT
```

Now, we have to update the `/etc/fstab`. In the end of `fstab` file add the
following line:

```
//10.0.2.4/qemu         /home/YOUR_USER/shared/  cifs    uid=1000,credentials=/root/.cifs,x-systemd.automount,noperm 0 0
```

Finally, we just need two more commands:

```
[inside_vm] $ mkdir shared
[inside_vm] $ sudo systemctl daemon-reload
```

Reboot your VM, start it using the command mentioned early, then access it via
ssh, and try to access the `shared` directory. If everything works well, you
should see the directory and files that you shared with your host machine.

## Conclusion

Keep in mind that we just scratched QEMU's surface, this tool provides many
features and have other tools for easily manage VMs. Finally, follow my feed
for new tutorials about QEMU and Linux development.

## Acknowledgments

I would like to thanks Charles Oliveira and Shayenne da Luz Moura for their
reviews and contributions for this tutorial.

## History

1. V1: Release

## References

1. [QEMU Arch Linux](https://wiki.archlinux.org/index.php/QEMU)
2. [QEMU Debian](https://wiki.debian.org/QEMU#Installation)
3. [QEMU](https://www.qemu.org/)
4. [Set up SSH key](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
5. [KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine)
6. [Official Arch Wiki - Install](https://wiki.archlinux.org/index.php/installation_guide)
7. [Arch Installation Tutorial](https://itsfoss.com/install-arch-linux/)
