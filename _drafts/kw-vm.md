---
layout: post
title: "kw VM: tools for handling VM"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

{% include add_ref.html id="libguestfsite"
    title="libguestfs: tools for accessing and modifying virtual machine disk images"
    date="2019-12-23"
    url="http://libguestfs.org/" %}

{% include add_ref.html id="qemusite"
    title="Qemu: generic machine emulator and virtualizer"
    date="2019-12-23"
    url="https://www.qemu.org/" %}

Originally, `kw` was created for make easier to work with QEMU VM; for this reason, we dedicate this post to discuss how `kw` can help you with VM.

# Overview

When I started to write `kw` my main goal was making the work with VMKS easy, specially, the way that I use QEMU VMs. Just for illustrate, the following command followed me in the beginning of my adventures in the Linux Kernel:

```
qemu-system-x86_64 -enable-kvm -net nic -net user,hostfwd=tcp::2222-:22,smb=$PWD/ \
                   -daemonize -m 4G -smp cores=4,cpus=4 vkms_vm 
```

I like this kind of command due to the flexibility provided by it, notice that I can change parameter related to the VM configuration really fast; this is useful for test VKMS under different conditions. However, command like that are hard to memorize and to type; I could create an alias for handling this sort of operation or maybe a small script for that, however, I decided to put it in a tool since this could be useful for many other people. After that, I started to work for adding support for handling QEMU VM.

Additionally, after talk with Helen Koike in Debconf 17, I added two requirements for `kw` support VMS:

1. Avoid turn-on a VM for install a new module; and
2. Avoid root command in the process of developing for Linux Kernel.

The last step, was important for Brazilians students that have limited access to machines in their university laboratories.

>  If you already read the below tutorials, you will enjoy this post a little bit more.
1. Play with Kernel Modules LINK
2. Kernel Compilation and Installation LINK
3.  Use QEMU to Play with Linux Kernel LINK
{: .info}

# Design

For making `kw` working as expected we need the following dependencies:

* _Libguestfs_ {% include cite.html id="libguestfsite" %}: this package provide tools for accessing and modifying virtual machine disk image;
* _Qemu_ {% include cite.html id="qemusite" %}: this tool is a generic and open source machine emulator and virtualizer.

**Note:**
Try to identify the package name for the above dependencies in your Distro.
{: .info}

In summary, `kw` work based on the combination of Qemu with Libguestfs. See Figure X illustrating how `kw` uses this tools:

IMAGE

With this combination we simplify the kernel workflow with a VM and also avoid the requirement of root operations.

# Commands

We just have a small set of command to take a look, however, let's try to describe each one.

> **Attention:**
> For the following commands we expected that you have the following requirements:
1. QEMU VM (If you don't have it, read this tutorial: LINK);
2. Kernel directory ready for work (If you don't have it, read this post: LINK);
3. All command are based on the Linux Kernel directory;
4. All dependencies described in the previous section installed and correctly configured.
{: .warning}

## Mount and Umount

`kw` provide the ability of mounting and umounting a QEMU image into a specific directory, however, before we use these commands let's take a look at the `kworkflow.config` file configuration in order to make sure that everything work well. See:

```
virtualizer=qemu-system-x86_64
mount_point=/home/YOUR_USER_NAME/p/mount
qemu_hw_options=-enable-kvm -daemonize -smp 2 -m 1024
qemu_net_options=-net nic -net user,hostfwd=tcp::2222-:22,smb=/home/YOUR_USER_NAME
qemu_path_image=/home/YOUR_USER_NAME/p/virty.qcow2
```

The above lines are an snippet from the default `kworkflow.config`, each of one of the lines describe how `kw` should behave. For example:

1. `virtualizer`: Defines the virtualization tool that should be used by `kw`, we only support QEMU at this moment;
2. `mount_point`: Defines where `kw` will mount the QEMU image, this directory is used by libguestfs during the mount/umount operation of a VM;
3. `qemu_hw_options`: Sets basic hardware configuration for QEMU;
4. `qemu_net_options`: Defines the network configuration.

For now, the most important options it are `mount_point` and `qemu_path_image`; make sure that this option point to the correct path. Now, you can finally try the mount command with:

```
kw mount # or just kw mo
```

If the above command work as expected you should see something in the directory pointed by `mount_point`, for example:

```
$ ls /home/siqueira/p/mount/
bin  boot  dev  etc  home  lib  lib64  lost+found  mnt  opt  proc  root  run  sbin  srv  sys  tmp  tracing  usr  var
```

Now, it is time to umount the directory with the following command:

```
kw umount # or: kw um
```

**Attention:**
The directory pointed by `mount_point` should be always empty before execute the command `kw mount` otherwise you will see an error message.
{: .info}

## Module install

Now that you verified that the mount and umount command work well, it is time to use an useful feature: install modules in a VM. For installing drivers in the VM you first need to make sure that the VM is not on and that you are in a Kernel directory. If so, you can try:

```
kw install # or just kw i
```

Under the hood, this command will execute the following steps:

1. Mount your QEMU image;
2. Install your kernel modules into the mounted directory;
3. Umount the QEMU image.

With these steps, you're ready for try your new modules installation.

**Attention:**
If you read "Play with Kernel Modules"LINK, I recommend you to try the same steps by now using `kw`.
{: .success}

## VM up

We already know how to mount/umount and install a new kernel modules, now it is time to start the VM and this task is really easy! Just use:

```
kw up # or just kw u
```

Now your VM should be running based on the parameter that you configured.

## SSH commands

Working on the native QEMU interface is not so comfortable every time, for this reason it is better to use ssh. If you already read the tutorial "Use QEMU to Play with Linux Kernel", you probably have a functional network between your host machine and the VM. In this case, you can just use:

```
kw ssh # or just kw s
```

This command will take a look in your `kworkflow.config` and use the following variable for connect to your VM:

* `ssh_ip`: by default it use `localhost`, but you can change it for any IP that you want;
* `ssh_port`: by default it use 2222, but you can change it.

The `ssh` feature provide other interesting features, such as the ability of run a command in the target machine. For example, you can try:

```
kw s --command="cat /etc/os-release" # or just kw s -c="cat /etc/os-release"
```

Additionally, if you have an repetitive task to execute in the target machine you can automate it in a script and let `kw` run it in the remote machine. For example:

```
kw ssh --script=/home/USER/my_glorious_script.sh # or just kw s -s=/home/USER/my_glorious_script.sh 
```

# Conclusion

Here we discussed some of the core features related to `kw`, notice that my goal here was just providing an overview about some of the interesting `kw` capabilities; we can expand this discussion for many different use cases however I tried to keep things simple and generic. In the next post, I'll talk about `kw deploy` feature. 
