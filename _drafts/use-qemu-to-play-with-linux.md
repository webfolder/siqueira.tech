---
layout: post
title:  "Use QEMU to Play with Linux Kernel"
date:   2019-02-15
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


## Command Summary

If you did not read this tutorial yet, skip this section. I added this section
as a summary for someone that already read this tutorial and just want to
remember a specific command.
{: .info}


```bash
qemu-img create -f qcow2 [NAME] 10G

qemu-system-x86_64 -cdrom ~/PATH/DISTRO_ISO.iso -boot order=d -drive \
                file=[NAME],format=qcow2 -m 2G

qemu-system-x86_64 -enable-kvm -net nic -net user,hostfwd=tcp::2222-:22,smb=$PWD/ \
                   -daemonize -m 4G -smp cores=4,cpus=4 [NAME]
```

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

QEMU is a generic machine emulator based on dynamic translation
{% include cite.html id="qemu" %} that can operate in two different modes
{% include cite.html id="qemuDebian" %}:

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
  path="posts/linux_kernel_basic/guest_host.png"
  style="width: 50%"
  caption="Workflow" %}

**Info:**
If you find any problem with this tutorial, please let me know. I will be glad
to fix it.
{: .info}

## Note

In this tutorial we will work inside and outside of a VM, for simplicity sake,
we will add the following comment on top of each command:

* `@VM`: Execute the command inside the VM.
* `@HOST`: Execute the command in your machine.

## Prerequisites: Installing QEMU, KVM and Openssh

To follow this tutorial you need to install QEMU and Samba Client (samba is
required for sharing directories between your host and guest).

### &rarr; On Arch Linux {% include cite.html id="qemuArch" %}:

```bash
# @HOST
sudo pacman -S qemu samba qemu-arch-extra openssh
```

### &rarr; On Debian {% include cite.html id="qemuDebian" %}:

```bash
# @HOST
sudo apt install qemu samba samba-client openssh
```

## Creating an Image

We want QEMU running a Linux distribution for our future experiments with
Linux. With this goal in mind, we have to create an image disk with the
following command:

```bash
# @HOST
qemu-img create -f qcow2 kernel_experiments 15G
```
**Attention:**
Don’t blindly copy and paste the command above or any other found in this
tutorial, try to understand it, by reading the brief description below the
command and examining the documentation.
{: .warning}


* `qemu-img`: It's the disk image utility provided by QEMU;
  * `create`: Indicates that we want to create new disk image, you can add options to enable or disable features;
  * `-f qcow2`: Specifies the image format; usually, you want 'raw' or
    'qcow2'. Raw images are fast, but it uses all the determined size at once;
    on the other hand, qcow2 is a little bit slower, but it increases the image
    size based on VM usage with the limit being the size given at creation;
  * `kernel_experiments`: This command will end up with an image file, and here is the name that we assign; feel free to change it;
  * `15G`: The image size.

In this tutorial, I recommend using qcow2 with 10 or 15G.

Finally, check if everything is fine by with the command:

```bash
# @HOST
file kernel_experiments
```

The output of the command above, should be something similar to `kernel_experiments: QEMU QCOW Image (v3), 16106127360 bytes`

## Installing a Distro

Next, download any Linux distribution image you want to use (I recommend Debian
or ArchLinux {% include cite.html id="installArch" %} {% include cite.html id="installArch2" %},
but it can be any). With your QEMU image file created above and your distro's
ISO, follow the command below:

```bash
# @HOST
qemu-system-x86_64 -cdrom ~/PATH/TO/YOUR_DISTRO_ISO.iso -boot order=d -drive file=kernel_experiments,format=qcow2 -m 2G
```

The command above will start up a VM and mount the ISO file you've downloaded
on it. After installation has finished, it'll reboot the VM automatically.
{: .success}

Proceed with the installation, and come back here after you finish. For the
sake of simplicity, **create a user in the VM that match with your host machine
user**.

## Booting up a QEMU VM

Finally, it is time to start the machine. Take a look at the command below and
adapt it for your needs:

```bash
# @HOST
qemu-system-x86_64 -enable-kvm -net nic -net user,hostfwd=tcp::2222-:22,smb=$PWD/ -daemonize -m 2G -smp cores=4,cpus=4 kernel_experiments
```

* `qemu-system-x86_64`: Command that start the QEMU VM.
  * `-enable-kvm`: Enable full virtualization by using KVM {% include cite.html id="kernelVM" %};
  * `-net`: Network options;
  * `-daemonize`: Daemonize the QEMU process after initialization;
  * `-m`: RAM size;
  * `-smp`: Simulate a SMP system with n CPUs.

This command will pop up a window with the recently installed distribution from
the step before. For detailed information about the options used in this
command, take a look at the man page.

In some distros, the above command fails or show a warning due to the
`-enable-kvm` parameter. Probably, your host user isn't part of the KVM
group. You can fix it by adding yourself to the KVM group. For example:
`sudo usermod -a -G kvm $USER`. Finally, reboot your machine.
{: .warning}

## Configuring SSH

At this point, probably you can log in and out of the VM by typing the VM's
user's password; this can be cumbersome during the work.

To make your work experience better, follow the steps below for creating a
passwordless ssh connection, using an RSA key pair.

**Info:**
There're many ways for setting up an SSH connection; here's a 1000 foot view of
the process.
{: .info}

First, create an RSA key pair on the host machine (if there isn't any already)
with the command:

```
# @HOST
ssh-keygen -t rsa # Note: For full passwordless, do not add a password in this step
```

Explaining the above command is beyond this tutorial. There's plenty of
information about it on the Internet {% include cite.html id="sshDo" %}. After
the key is set up, you need to prepare the recently created VM to accept ssh
connections. Just install the package `openssh` on it (Arch: openssh, Debian:
openssh-server).

Since you are working in a fresh installation, you will need to temporally
enable password authentication in the VM in order to log in from the host
machine. Follow the steps below:

1. In the VM: `sudo sed -i 's/#.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config`;
2. Restart the service: `sudo systemctl restart sshd`.

Now, from the host machine test logging in into the VM with:

```
# @HOST
ssh -p 2222 127.0.0.1
```

Note that the above command will try to log into the VM using the default
host's username, which is $USER.
{: .warning}

If everything works as expected, at this point, you can access the VM's shell.
Moving on, log out of the VM, and from the host machine type the following:

```
# @HOST
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
# @HOST
sudo pacman -S samba cifs-utils
```

### &rarr; Debian

```
# @HOST
sudo apt install samba cifs-utils
```

Second, start the VM and install the same packages.

```
# @HOST
qemu-system-x86_64 -enable-kvm -net nic -net user,hostfwd=tcp::2222-:22,smb=$PWD/ -daemonize -m 2G -smp cores=4,cpus=4 kernel_experiments

$ ssh -p 2222 127.0.0.1

# @VM
sudo pacman -S samba cifs-utils
```

Now, we want to make an automatic setup in our VM that make the directory
shareable on-demand, i.e., the VM and host start to share a directory if the
user tries to access the folder. For doing it, we have to create a new
`systemctl` entry.

Before we start this step, it is important to highlight that you need to
customize some of the steps described hereafter; basically, you have to replace
``USER`` by your username.

1) Let's start by create the file `home-USER-shared.mount` (e.g.,
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
{: .info}

2) Additionally, create another file named `.cifs` in `/root/` with the
   following content:

```
username=YOUR_USER_NAME
password=ANY_PASSWORD_YOU_WANT
```

3) We have to update the `/etc/fstab`. In the end of `fstab` file add the
following line:

```
//10.0.2.4/qemu         /home/USER/shared/  cifs    uid=1000,credentials=/root/.cifs,x-systemd.automount,noperm 0 0
```

4) Now we to create a shared directory:

```
# @VM
mkdir shared
```

5) Finally, we have to put the finishing touches to `systemctl`:

```
# @VM
sudo systemctl daemon-reload
sudo systemctl enable home-USER-shared.mount
sudo systemctl start home-USER-shared.mount
```

6) Try to access the shared directory created on step 4.

Reboot your VM, start it using the command mentioned early, then access it via
ssh, and try to access the `shared` directory. If everything works well, you
should see the directory and files that you shared with your host machine.

## Conclusion

Keep in mind that we just scratched QEMU's surface, this tool provides many
features and have other tools for easily manage VMs. Finally, follow my feed
for new tutorials about QEMU and Linux development.

## Acknowledgments

I would like to thanks Charles Oliveira, Shayenne da Luz Moura, Rodrigo
Ribeiro, Matheus Tavares, Melissa Wen, and Marcelo Schmitt for their reviews
and contributions for this tutorial.

## History

1. V1: Release
2. V2: Improve highlights
3. V3: Add Melissa suggestions in some of the steps

{% include print_bib.html %}
