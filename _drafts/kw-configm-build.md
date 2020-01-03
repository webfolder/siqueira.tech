---
layout: post
title: "kw build tools: introduce config manager and build wrapper"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

This is the second post about `kw` features, here we want to explore tools provided by `kw` that manages `.config` and the Linux kernel build.

# Overview

The `.config` file holds all the information about what should be compiled or not during the build process, and this is an important file for Kernel developers because when you have a functional `.config` file they you use it most of the time. Usually, we need a `.config` file for different set of machines; for example, you need one `.config` file for compile your kernel for Raspberry pi and a different on for your x86 machine. After you have this `.config` file, you will need to compile the kernel by taking advantage of your hardware. With these tasks in mind, we will describe how `kw` can make you life easier by describing the `configm` and `build` option provided by `kw`.

**Info:**
All examples in this tutorials will suppose that you are in a Linux Kernel directory.
{: .info}

# Config manager

The `configm` option stands for _config manager_ and it is responsible for managing different versions of the `.config` file. It provides the save, load, remove, and list operations of such files. Let's see each one of these options in a convenient sequence.

## Save

The save options relies on a `.config` file in the current directory by searching for the `.config` file. If you want to save the current `.config`, you have to specify a name for the file and if you can also add a description if you want. Let's see one example:

1. First of all, check if you have a `.config` file, if you don't have get a new one.
```
ls -a | grep .config
```
2. Save your current `.config` file with the following command:
```
kw configm --save MY_CONFIG_FILE -d "My first config file saved by kw"
```
If you want, you can suppress the description and use:
```
kw configm --save MY_CONFIG_FILE
```
You can also use the short options:
```
kw g -s MY_CONFIG_FILE
```

Under the hood, `kw` copy your `.config` file to a directory under its management and it use git for save your config file.

**Completely remove configs:**
By default, if you install and uninstall `kw` it will not affect your `.config` files under the management of `kw`. However, if you want to clean everything, you can use the option `./setup --completely-remove` however be aware that you will lost all your `.config`.
{: .danger}

## List

After save many of your precious `.config` file, you probably want to list them for later use. In this case, you just have to use:

```
kw configm --ls
```

You will see something like this:
```
Name                           | Description

aspire-vx-arch                 | My laptop Config
vkms                           | My VKMS config
```

## Get

You already save your `.config` file, now it is time to retrieve it, and this task is really trivial; you just need to know in advance the name of the `config` file that you want to use. For example:

```
kw configm --get vkms
```

That's it! You `.config` file will be copied to your current directory. If you already have a `.config` file in your local directory, `kw` will ask you if you want to override it; if you are sure that you want to replace the current `.config` file you can use `-f`. See:

```
kw configm --get vkms -f
```

**Take care with `-f` option:**
If you use `-f` you should be aware that the current `.config` file will be removed and you will not be able to recover it.
{: .danger}

## Remove

After a long time using `kw configm̀` it is natural that your list of `.config` file get huge and probably outdated. If you want to remove `.config` files from `kw` list, you can use the `--rm` option. For example:

```
kw configm̀ --rm vkms
```

**Attention:**
If you accidentally remove a `.config` file from `kw` list you can recover it manually by accessing the directory `~/.config/kw/configs` and manually take it from the git log.
{: .warning}

# Kw build

As a kernel developer, you probably will compile the Kernel multiple times and `kw` will provide support for you building your Linux Kernel. We don't have to much things to do here, just:

```
kw build
```

or just:

```
kw b
```

This command will detect the number of cores available in your machine, and based on that define the number of threads used by GCC (`j[#CORES]`). This command also take a look on the `kworflow.config` for getting the target architecture for your kernel, you can change the value `arch` in the `kworflow.config`.

# Conclusion

In this post, we went through `configm` and `build`, we covered most of the aspects related with these features. In the next tutorial, we will cover a set of features related with QEMU VM and how to install/update kernel in the VM.
