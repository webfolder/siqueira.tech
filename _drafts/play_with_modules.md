---
layout: post
title:  "Play with Kernel Modules"
date:   2019-04-07
author: siqueira
categories: "linux-kernel-basic"
lang: en
---

{% include add_ref.html id="iioDummySource"
    title="IIO dummy source code"
    url="https://github.com/torvalds/linux/tree/master/drivers/iio/dummy" %}

{% include add_ref.html id="perilsPrInfo"
    author="Jonathan Corbet"
    title="The perils of pr_info()"
    url="https://lwn.net/Articles/487437/"
    year="2012/03/21" %}

{% include add_ref.html id="compilationInstallation"
    author="Rodrigo Siqueira"
    title="Kernel Compilation and Installation"
    url="https://flusp.ime.usp.br/others/2019/02/16/Kernel-compilation-and-installation/"
    year="2019/02/16" %}

{% include add_ref.html id="linuxKernelModules"
    title="Linux kernel modules"
    url="http://linux-training.be/sysadmin/ch28.html#idp68121456" %}

{% include add_ref.html id="linuxModeInfo"
    title="Linux modinfo command"
    author="Computer Hope"
    url="https://www.computerhope.com/unix/modinfo.htm"
    year="07/12/2017" %}

## Command summary

If you did not read this tutorial yet, skip this section. I added this section
as a summary for someone that already read this tutorial and just want to
remember a specific command.
{: .info}


```bash
make modules
make M=driver/<TARGET_DRIVER>
sudo make modules_install
modinfo <DRIVER_NAME>
lsmod | grep <DRIVER_NAME>
dmesg -H
sudo modprobe <TARGET_DRIVER>
sudo modprobe -r <TARGET_DRIVER>
modprobe --show-depends <module>
```

## Introduction

During my first attempts to start working with Linux Kernel, I read many books
and tutorials about device drivers. Although most of them had examples of
compiling an external module, some things were still not so clear to me. I was
a newcomer, and I needed well comprehend how to compile and install in-tree
modules for starting my work with kernel drivers.

> How can I compile a single in-tree module? How can I install it? Doubts still
lingered in my mind...

I confess that I had difficult to achieve this task for the first time; it took
me a half of day to learn the essential steps. Nowadays, I see that this is a
simple task; however, I want to shed some lights on this issue to help
newcomers.

For this tutorial, I decided to work with a module named IIO dummy
(`driver/iio/dummy` {% include cite.html id="iioDummySource" %}) because we can
conduct some experiments with that in future tutorials. Please note that the
steps and tips described here apply easily to other modules.

Some of the operations described here requires `sudo`. If you are not 100%
comfortable with Linux system or you are a newcomer, I strongly advise you to
start working inside a virtual machine; you can read more about this here:
[Use Qemu to play with Linux Kernel]().
{: .warning}

## Compile In-tree Module

When we start to work with in-tree drivers, we want to spread some `pr_info` {%
include cite.html id="perilsPrInfo" %} around the code and make other small
changes to find a way to understand the code. In this sense, every time that we
made a change, we could compile the modules with the following command:

```bash
make modules
```

The above command works pretty well, and I still use it in the present day.
Note that only `make` works, too. Sometimes, we just want to compile and clean
a single module. To do this, I found out the following command:

```bash
make M=driver/iio/dummy
```

The parameter `M` expects a path to the target driver. This allows you to
compile and clean a target module without touching other drivers. For example,
try:

```bash
make M=driver/iio/dummy clean
```

This command has a small trick: your module must be enabled in the .config
file, and your kernel should be compiled with this option before you use `M`.
If you don’t know how to do it, take a look at
{% include cite.html id="compilationInstallation" %}
{: .warning}

## Install In-tree Module

Before introducing you to the module installation method, it is worth to
elaborate a little about loadable modules in a Linux file system. First of all,
try the commands below:

```bash
$ uname -r
4.9.0-8-amd64

$ ls /lib/modules
4.9.0-6-amd64  4.9.0-7-amd64  4.9.0-8-amd64
```

The command `uname -r` print the kernel release and the `/lib/modules`
directory stores all modules {% include cite.html id="linuxKernelModules" %}.
It is important to notice that in `/lib/modules/` each version of kernel
compiled for your system has its directory; from the practical point of view if
you install a new module, you can check it in here.

For installing the module, I use the command:

```bash
sudo make modules_install
```

If you are working in a module and for any reason, you decide to install a
modified version of it, you should take a careful look at (1) `/lib/modules/`,
(2) `uname -r`, and (3) the current kernel version that you are working. A
common mistake is installing modules from the latest kernel version without
update the kernel image.
{: .warning}

## Load and unload

GNU/Linux can dynamically load kernel modules; from the user perspective, users
can load modules during the execution time. There's a different way to load
and unload modules, and we will briefly describe it in this section.

### `modprobe` vs `insmod`

When I started to play with modules, I tried to work with `insmod` and `rmmod`
command. Nonetheless, as someone that just begin to work with drivers, these
commands made my work experience painful because they make it easy to produce a
kernel panic. After long hours of reading and debug, I realized why people
always recommend the command `modprobe`. To understand how module load works,
keep in mind that all drivers installed in the system can be found at
`/lib/modules/$(uname -r)`. Also, it is essential to know that `modprobe`
command is a wrapper for `insmod` and `rmmod`. By the way, the command
`modprobe` makes it easier to load and unload modules because it handles
dependencies for you and avoids kernel problems.

Ok, let's try to load the module with the following command:

```bash
sudo modprobe iio_dummy
```

Besides the output from `modprobe` command, you can also verify if everything
is fine with the command `lsmod | grep <TARGET_MODULE>` or by taking a look at
the end of the `dmesg` log. Try:

```bash
lsmod | grep iio_dummy

dmesg -H
```

If you want to remove a modules, you can try:

```bash
sudo modprobe -r iio_dummy
```

### Compile Kernel Module Outside from In-Tree

It is possible to develop a driver as a separate project from the Kernel. In
this tutorial, we are only interested in how to load and unload modules; in
this sense, I want to introduce commands `insmod` and `rmmod`. First,
download a simple module at:

[Download]({{ site.baseurl }}/files/simple_dd.tar.gz)

Extract the project file with:

```bash
tar -xaf simple_dd.tar.gz
```

Compile the module with:

```bash
cd simple_dd
make
```
To test this module, it would be nice for you to open two terminals side by
side. In a terminal, just type `dmesg -wH` and, in the other, type:

```bash
sudo insmod hello_world.ko
sudo rmmod hello_world
```

## Tips and Troubleshoots

Here I want to add some tips and troubleshoots briefly. I will probably update
this section in the future. If you have any helpful advice to improve this
section, please mail it to me.

### Check Installed Module

Sometimes, I do not feel confident that my module has been loaded correctly;
because of this, I like to add some prints or make a simple change in the code.
The most straightforward approach to check if your module was correctly loaded
in the system is changing the `MODULE_DESCRIPTION` macro and check the metadata
with the command modinfo. For example, change the line `MODULE_DESCRIPTION` in
any driver that you use with something like that:

```c
MODULE_DESCRIPTION("YEP... I LOADED THE CORRECT DRIVER");
```

Then install and load the module again; after that, you can check the
description with the `modinfo` command. For example:

```bash
$ modinfo iio_dummy
filename:       /lib/modules/4.16.0-rc3-TORVALDS+/kernel/drivers/iio/dummy/iio_dummy.ko.xz
license:        GPL v2
description:    YEP... I LOADED THE CORRECT DRIVER
author:         Jonathan Cameron <jic23@kernel.org>
srcversion:     1C4C5F875A87E3DFD4F2820
depends:        industrialio-sw-device,industrialio,iio_dummy_evgen,kfifo_buf
retpoline:      Y
name:           iio_dummy
vermagic:       4.16.0-rc3-TORVALDS+ SMP preempt mod_unload modversions
```

The command `modinfo` collects information from the Linux kernel modules
directory {% include cite.html id="linuxModeInfo" %}. This is really useful, to
help you to figure out if your module is correctly loaded. A common mistake is
to compile the module with a different kernel target, this produces errors such
as:

```bash
FATAL: Module drivers/<path> not found in directory /lib/modules/<kernel_version>
```

If you get this error, the tip above can help you to figure out what is wrong.
Lastly, remember to verify the kernel Makefile to be sure about your kernel
version or your distro version.

### Get Dependencies Information

Sometimes, it is important to know the modules dependencies. You can use the
following command:

```bash
$ modprobe --show-depends <module>
```

Why is this important? If you try something really radical as `rmmod -f`, it is
a good idea to know the exact dependencies related to your device.

From my experience, it is not a good idea to use `rmmod -f` with large modules.
It is ok, if the module is small or if you make it. If you really know what you
are doing, use it; if not, avoid. Prefer `modprobe -r`
{: .success}


## Acknowledgments

I would like to thanks Melissa Wen for her detailed review. I really appreciate
you taking the time out to share your feedback.


## History

1. V1: Release

{% include print_bib.html %}
