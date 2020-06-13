---
layout: post
title: "kw for handling virtual machine"
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

Originally, `kw` was devised to improve the work with QEMU virtual machine
(VM); for this reason, we dedicate this post to discuss how `kw` can help with
your kernel workflow using VM.

# Command summary

**If you did not read this tutorial yet, skip this section. I added this
section as a summary for someone that already read this tutorial and just want
to remember a specific command.**
{: .info-box}

```bash
kw mount # or just kw mo
kw umount # or: kw um
kw install # or just kw i
kw up # or just kw u
kw ssh # or just kw s
kw s --command="cat /etc/os-release" # or just kw s -c="cat /etc/os-release"
kw ssh --script=/PATH/SCRIPT.sh # or just kw s -s=/PATH/SCRIPT.sh
```

# Overview

I started to write `kw` with the intention to simplify my work with VMKS,
especially, the way that I interact with QEMU VMs. Just for illustrate my
point, when I started to work on Linux, I constantly typed commands such as:

```bash
qemu-system-x86_64 -enable-kvm -net nic \
                   -net user,hostfwd=tcp::2222-:22,smb=$PWD/ \
                   -daemonize -m 4G -smp cores=4,cpus=4 vkms_vm
```

The above line shows how powerful QEMU can be since it can be finely customized
with many interesting options. Of course that command like that is hard to
memorize and type, I could create an alias or a small script for handling this
sort of operation. Nonetheless, I decided to put the QEMU manipulation in a
single and centralized tool since this could be useful for other people. The
final argue for adding a dedicated support for QEMU work on `kw` was raised in
a talk with Helen Koike in the Debconf 17, when she provided the following
requirement for [lkcamp](https://lkcamp.gitlab.io/) group:

1. Avoid turn-on a VM for installing a new module; and
2. Avoid root command in the process of developing for Linux Kernel.

The last step, was important for Brazilians students that have limited access
to machines in the university laboratories.

> If you already read the below tutorials, you will enjoy this post a little bit more.
1. Play with Kernel Modules LINK
2. Kernel Compilation and Installation LINK
3. Use QEMU to Play with Linux Kernel LINK
{: .info-box}

# Design

For providing a better user experience using `kw` with a VM, we added the
following dependencies:

* _Libguestfs_ {% include cite.html id="libguestfsite" %}: this package provide
  tools for accessing and modifying virtual machine disk image;
* _Qemu_ {% include cite.html id="qemusite" %}: a generic and free software
  machine emulator and virtualizer.

> **Note:**
Try to identify the package name for the above dependencies in your Distro.
{: .info-box}

# Commands

We just have a small set of command to take a look, however, let's try to
describe each one.

> **Attention:** For all commands described in the rest of this page we
expected that you have the following requirements:
1. QEMU VM (If you don't have it, read this tutorial: LINK);
2. Kernel directory ready for development (If you don't have it, read this
   post: LINK);
3. From now on, all command is executed inside the kernel directory;
{: .warning-box}

## Mount and Umount

`kw` provide the ability to mount and umount a QEMU image in a specific
directory, however, before using these commands, let's take a look at the
`kworkflow.config` file in order to make sure that everything works well. After
you open it, you should see something like this:

```bash
virtualizer=qemu-system-x86_64
mount_point=/home/YOUR_USER_NAME/p/mount
qemu_hw_options=-enable-kvm -daemonize -smp 2 -m 1024
qemu_net_options=-net nic -net user,hostfwd=tcp::2222-:22,smb=/home/YOUR_USER_NAME
qemu_path_image=/home/YOUR_USER_NAME/p/virty.qcow2
```

The above lines are a snippet from the default `kworkflow.config`, each one of these lines describes how `kw` should behave. For example:

0. `virtualizer`: Defines the virtualization tool that should be used by `kw`,
   we only support QEMU at this moment;
1. `mount_point`: Defines where `kw` will mount the QEMU image, this directory
   is used by `libguestfs` during the mount/umount operation of a VM;
2. `qemu_hw_options`: Setup the hardware resources for QEMU;
3. `qemu_net_options`: Defines the network configuration.

For this section, the most important options are `mount_point` and
`qemu_path_image`; make sure that these options point to the correct path.
Now, you can finally try the mount command with:

```bash
kw mount # or just kw mo
```

If the above command works as expected you should see something like the output
below in the `mount_point` directory:

```bash
$ ls /home/siqueira/p/mount/
bin  boot  dev  etc  home  lib  lib64  lost+found  mnt  opt  proc  root  run  sbin  srv  sys  tmp  tracing  usr  var
```

Now, it is time to umount the directory with the following command:

```bash
kw umount # or: kw um
```

> **Attention:**
The directory pointed by `mount_point` should be empty before you run `kw
mount` otherwise you will see an error message.
{: .warning-box}

## Module install

Now that you verified that the mount and umount command work well, it is time
to use a useful feature: install modules in a VM. This option requires that you
make sure that the VM is off and that you are in a Kernel directory. If so, you
can try:

```bash
kw deploy --vm --modules # or just kw d --vm --modules
```

Under the hood, this command will execute the following steps:

1. Mount your QEMU image;
2. Install your kernel modules into the mounted directory;
3. Umount the QEMU image.

> **Attention:**
If you have read "Play with Kernel Modules"LINK, you will notice that `kw d --vm --modules`
automate most of the work described on that page.
{: .info-box}

## VM up

In the previous installment we learned how to install a module in a VM, now it
is time to start the VM:

```bash
kw up # or just kw u
```

It was a piece of cake, right? Now your VM should be running based on the
parameter that you configured.

## SSH commands

If you already worked on the QEMU window you probably notice that using such
resource is a little bit tiresome and cumbersome, for this reason it is better
to use ssh. You can add the IP and port information in the `kworkflow.config`
to simplify your access to the VM, after that, you can just use:

```bash
kw ssh # or just kw s
```

> If you already read the tutorial "Use QEMU to Play with Linux Kernel"LINK,
you probably have a functional network between your host machine and the VM.
{: .info-box}

This command takes a look in your `kworkflow.config` and uses the following
variable to connect to your VM:

* `ssh_ip`: by default, it set to `localhost`, but you can change it for any IP
  that you want;
* `ssh_port`: it use 2222, but you can change it.

The `ssh` feature provides other interesting features, such as the ability to
run a command in the target machine. For example, you can try:

```bash
kw s --command="cat /etc/os-release" # or just kw s -c="cat /etc/os-release"
```

Additionally, if you have a repetitive task to execute in the target machine
you can automate it in a script and let `kw` run it in the remote machine. For
example:

```bash
kw ssh --script=/home/USER/my_glorious_script.sh # kw s -s=/home/USER/my_glorious_script.sh 
```

# Conclusion

Here we discussed some of the core features related to `kw`, notice that my
goal here was just providing an overview of some of the interesting `kw`
capabilities; we can expand this discussion for many different use cases
however I tried to keep things simple and generic. In the next post, I'll talk
about `kw deploy` feature (my favorite feature).
