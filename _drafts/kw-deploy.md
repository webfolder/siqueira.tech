---
layout: post
title: "kw deploy, automating kernel installation"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

Install and uninstall a new kernel image is one of the most common tasks for a
kernel developer, for this reason, `kw` automates the deploy in three different
contexts: virtual, local, and remote machine. This page is dedicated to
providing an overview of this feature.

# Command summary

**If you did not read this tutorial yet, skip this section. I added this
section as a summary for someone that already read this tutorial and just want
to remember a specific command.**
{: .info-box}

```bash
kw deploy --remote IP:PORT # e.g., kw d --remote 172.16.254.1:22
kw deploy # kw d
kw deploy --vm
kw deploy --local
kw deploy --ls # kw d -l
kw deploy --ls-line # kw d -s
kw deploy --uninstall KERNEL_TARGET # kw d -u
```

# Overview

When we try to fix a bug or try to implement a new feature in the Kernel, we
have to test it somehow. The most common way to test your work start by
generating a new Kernel and module binaries, next you install it in a test
machine (or a VM or even your host machine), and finally checks your
implementation. In the page NOME_COM_LINK we cover with details each step
related to a Kernel installation, from that you may remember that we need to
pay attention into multiple steps; in the beginning it is interesting to
execute each step, however, it rapidly becomes a really boring task. The
situation gets worse, if you work with different kernel targets and different
distros.

For all of these reasons, we decided to implement a feature in `kw` named
**deploy**. This component has the mission of making it easy to install a new
Kernel version in a target machine and make it in a flexible way that we can
support multiple distros.

> **Attention:**
Deploy feature rely in the Linux kernel repository, for this reason you have to
execute this command inside of the Kernel repository.
{: .warning-box}

# Introduction to deploy option

For better understand how the deploy option works, you first need to know the
three different types of targets that `kw deploy` supports:

0. **Remote**: It is any machine that you have a connection and root
   privileges;
1. **vm**: It is a QEMU image with one of the distros supported by `kw`;
2. **local**: It is your host machine, i.g., your laptop or desktop;

The deploy option can be invoked as `kw deploy` or just `kw d`, and of course,
it has some options in which the most commons are:

* `--modules`: This option requests `kw` to only deploy modules. In other
  words, this command will only handle the modules files to the target machine;
* `--reboot`: This option reboot the target machine after the deploy
  installation finish;
* `--ls`: list installed kernels;
* `--uninstall`: Removes one or multiple kernels **installed via `kw`**;

It is important to highlight that you can take advantage of the
`kworkflow.config` file and customize it for better support your common `kw
deploy` options. We have the following interesting options:

* `default_deploy_target`: Set a default target to deploy (e.g, remote, local,
  or vm), if you do not specify anything in the command line, this option is
  retrieved by `kw`. For example, `default_deploy_target=remote`;
* `reboot_after_deploy`: If you always want to reboot the machine after you
  execute the deploy command, you can add `yes` for this option. Otherwise,
  just add `no`.

Now, let's dive a little bit in the `kw deploy` options.

## Remote

This option is the most generic deploy option because it relies on a network
connection to install any new Kernel which makes this option available for all
sorts of targets (remote, vm, and local). For example, if you have a way to
connect into your virtual machine via ssh you can deploy a new kernel by using
the remote option or if you use the localhost as your target you can also
deploy a new kernel version to your host machine.

For obvious reason, if you want to deploy a new kernel in a remote machine or
your localhost you need the required permission; however, **never** run `kw` as
`root` unless you know what you are doing. It is important to highlight that
`kw` uses `/root` directory for storing temporary data used during the deploy,
if you want to inspect this file take a look at `/root/kw_deploy/`.

To avoid polluting your workspace with temporary data, `kw` also creates a
directory at `~/.cache/kw` with two subdirectories: `remote` and `to_deploy`.
If the deploy finished without errors, `kw` will clean up the temporary files;
however, if you want to clean the cache by yourself you can use `kw
clear-cache`.

Ok, now it is time to show a practical example. Suppose that you have a remote
machine available and you want to deploy a new kernel image, you just need to
use:

```bash
kw deploy --remote 172.16.254.1:22
# or you can just use
kw d --remote 172.16.254.1:22
```

If you deploy a new kernel image multiple times, type the above command can be
tedious. For avoiding to repeat yourself, you can specify your current work
scenario by simply change `kworkflow.config` as the example below illustrates:

```bash
ssh_ip=172.16.254.1
ssh_port=22
...
default_deploy_target=remote
reboot_after_deploy=no
```

> The option `ssh_ip` also accept the format `USER@DOMAIN`, e.g.,
 `siqueira@my_debian`
{: .info-box}

After update your `kworkflow.config` with the above changes, you just need to
use:

```bash
kw deploy # kw d
```

## VM

`kw` originally born to be used with QEMU, for this reason, we can deploy to a
QEMU VM with the option `--vm`. The way that `kw` handles a VM depends on
`libguestfs` which is used to mount a QEMU image in a filesystem and after that
operate over the mounted directory. Before starting to use this option, take a
look at `kworkflow.config` and update the following options:

```bash
mount_point=/home/USERKW/p/mount
qemu_path_image=/home/USERKW/p/virty.qcow2
```

* `mount_point`: target directory for mounting the QEMU image;
* `qemu_path_image`: QEMU image path.

> Read LINK for extra details about `kw vm`
{: .info-box}

After you specify the above parameters, you are ready for deploying a new
kernel module in the VM; but first, make sure that you turned off your VM and
use:

```bash
kw deploy --vm
```

This command will mount the QEMU image in the specified path, and after that it
will install a new set of modules in the VM. After the process finish, you can
turn-on the VM and see the change.

> **Attention:**
Unfortunately, `kw deploy --vm` does not deploy a new kernel image yet, for
more information about it take a look at [Deploy new Kernel image for QEMU VM
with libguestfs](https://github.com/kworkflow/kworkflow/issues/139). However,
you can use `kw deploy --remote` to overcome this limitation.
{: .warning-box}

## Local

Finally, `kw deploy` also supports a new kernel installation in your host
machine. Suppose that you want to install the latest version of the Linux
kernel in your Arch/Debian/Ubuntu system, you just need to use:

```
kw deploy --local
```

> **Attention:**
This operation requires a root privileges.
{: .error-box}

# Conclusion

On this page we covered the use of the `deploy` option in three different
scenarios. Keep in mind that we have a lot of work to do in this part of the
code, we want to make this feature more generic and customizable; if you like
it, help us to improve `kw`. We have a lot of open issues in our repository.

For the next post related to `kw` I want to discuss a little bit about the
source in order to encourage people to help us to make `kw` better.
