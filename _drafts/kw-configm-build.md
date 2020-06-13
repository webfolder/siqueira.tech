---
layout: post
title: "kw build and configm"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

This post first covers `.config` manager and later we explain the Linux kernel
build.

## Command summary

**If you did not read this tutorial yet, skip this section. I added this
section as a summary for someone that already read this tutorial and just want
to remember a specific command.**
{: .info-box}

&rarr; Config manager:

```bash
kw configm --save FILE_NAME -d "Description"
kw g -s FILE_NAME
kw configm --ls
kw configm --get vkms
kw configm̀ --rm vkms
```

&rarr; build:

```bash
kw build # kw b
```

# Overview

The kernel `.config` file holds all modules and kernel components required
during the build process, this is an important file for Kernel developers. It
is not rare the need for using different `.config` file for a different set of
machines, for example, you may have one `.config` file for compiling your
kernel for Raspberry pi and another one for your x86 machine. `kw` tries to
simplify the `.config` file management by providing a subcommand named
`configm` which is one of our topics in this post. The second subject of this
post is a feature named `build` that manages the kernel compilation.

**Info:**
All examples in this tutorial suppose that you are in a Linux Kernel directory.
{: .info-box}

# Config manager

The `configm` option stands for _config manager_ and it is responsible for
managing different versions of the `.config` file. In a few words, this
functionality provides the save, load, remove, and list operations of such
files. Let's see each one of these options in the following subsection.

## Save

`kw` provide a mechanism for keeping track of `.config` files, see below how to
do it:

0. First of all, check if you have a `.config` file in your kernel directory;
   if you don't have it, now it is time to get one.
```bash
ls -a | grep .config
```
1. Save your current `.config` file with the following command:
```bash
kw configm --save MY_CONFIG_FILE -d "My first config file saved by kw"
```
If you want, you can suppress the description, for example:
```
kw configm --save MY_CONFIG_FILE
```
You can also use short options:
```
kw g -s MY_CONFIG_FILE
```

Under the hood, `kw` copy your `.config` file to a directory under its internal
management and it uses git for keeping track of your `config` file.

**Completely remove configs:**
By default, if you install and uninstall `kw` it will not affect your `.config`
files under `kw` management; however, if you want to clean everything, you may
use the option `./setup --completely-remove`.
{: .error-box}

## List

After saving many of your precious `.config` file, you probably want to list
them for later use. In this case, you just have to use:

```
kw configm --ls
```

You will see something like this:

```
Name                           | Description

aspire-vx-arch                 | My laptop Config
vkms                           | My VKMS config
```

## Retrieve an `.config` file

You already saved your `.config` files, now it is time to retrieve one of them,
and this task is really trivial; you just need to know in advance the name of
the `config` file that you want to use. For example:

```
kw configm --get vkms
```

That's it! Your `.config` file will be copied to your current directory. If you
already have a `.config` file in your local directory, `kw` will ask you if you
want to override it. If you are sure that you want to substitute the current
`.config` file you can use `-f`. See:

```
kw configm --get vkms -f
```

**Take care with `-f` option:**
If you use `-f` you should be aware that the current `.config` file will be
removed and you no longer able to recover it.
{: .danger}

## Remove

After a long time using `kw configm` it is natural that your list of `.config`
file gets huge and probably outdated. If you want to remove `.config` files
from `kw` list, you can use the `--rm` option. For example:

```
kw configm̀ --rm vkms
```

**Attention:**
If you accidentally remove a `.config` file from `kw` list you can recover it
by manually accessing the directory `~/.config/kw/configs` via git commands.
{: .warning}

# Kw build

As a kernel developer, you will probably compile the Kernel multiple times and
`kw` also automates this task for you. We don't have too many things to do
here, just:

```
kw build
```

or simply:

```
kw b
```

This command will detect the number of cores available in your machine, and
based on that define the number of threads used by GCC (`j[#CORES]`). This
command also inspects the `kworflow.config` for getting the target architecture
for your kernel, you can change the  `arch` variable in the `kworflow.config`.

# Conclusion

In this post, we went through `configm` and `build`, we covered most of the
aspects related to these features. In the next tutorial, we will cover a set of
features related to QEMU VM and how to install/update kernel in the VM.
