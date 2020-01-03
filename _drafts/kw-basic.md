---
layout: post
title: "Introduce kw: a tool for support kernel developers"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

This post is the first part of a series of publication that discribes a tool named Kernel Workflow, or just kworkflow or kw.

# What is it kw?

`kw` stand for Kernel Workflow, and it is a tool that aim to support Linux kernel developers by automate some of the repeated tasks that they have. Just for provide an overview, we currently support:

1. Handle kernel code style
2. Handle Kernel maintainers
3. Manage `.config` files
4. Support with ssh command
5. Manage build
6. Manage deploy of new kernel or module version
7. Handle QEMU virtual machine

We have a plan to add other features, specially some features that could be useful for maintainers. Additionally, if our community grows, we want to support other projects that following the Linux kernel workflow.

# Why I started it?

I started my carrer as a Kernel developer in 2018, when I started to prepare for apply to Google Summer of Code. In the moment, I was learning the basic stuff such as compile and install a new kernel version in a target machine, as a result, I start to write some simple shell scripts. However, during my first week as a GSoC student, Gustava Padovan (one of my mentor) introduced me to his set of [scripts for working](https://github.com/padovan/scripts) with kernel and started to use it. After make a lot of improvements and take other people scripts, I decided to start a project that unify these kind of scripts because I just noticed that all kernel developers create their own tool for automate their work, so, I not put of this together in a single tool?

Tavares

# Our philosophy

`kw` is developed by [Matheus Tavares](https://matheustavares.gitlab.io/) and I, since Matheus contribute to `git` project we borrow some ideas from the git community for conduct this project. For the sake of brevity, I'll list our `kw` philosophy:

 - We got inpiration on the way that `git` works, because of this we copy how `git` handle its commands
 - We embrace tests, we try to add and improve every test that we have in `kw`
 - We document as much as we can, we try to document the code and also how to use `kw`
 - When we add a new feature, we try to not add external dependecy. We usually, prefer to adopt tools that can be find easily in most of the people environment
 - We try our best for have a stable version of `kw`, be we also have an unstable version that we try to improve

# How to install

For improve the experience of using `kw`, we have a script that do the hard work of installing `kw` in your system. Basically, if you want to try `kw` follow this steps:

0. For having a good experience with `kw`, you will need to install the following packages:
```
libguestfs qemu bash git python-docutils paplay notify-send
```
1. Get `kw` source code:
```
git clone https://github.com/kworkflow/kworkflow.git
```
2. Inside kworkflow directory, execute the following command:
```
./setup --install # or just ./setup -i
```
3. Reload your bashrc
```
source ~/.barshrc
```
4. Test your installation with the command:
```
kw help
```

## File paths

After install `kw` it will create some directories in your home, take a look at:

```
ls ~/.config/kw
ls ~/kw
```

Inspect all directories indicate above to see where `kw` store its data. Additionally, open your `~/.bashrc` for check a line added by the setup. Don't worry about these files right now, I'll publish another post that add more details about it.

## Configuration file

Inspired by `git` we use a global and local configuration file, you can see this configuration file in the directory:

```
~/config/kw/etc/kworkflow.config
```

Take a few minutes to read this file, it has a documentation for each parameter. Additionally, you can have an specific configuration per kernel project you just need a `kworkflow.config`in the local directory that you're working on. For example:

```
git clone https://anongit.freedesktop.org/git/drm/drm-misc.git
cd drm-misc
cp ~/.config/kw/etc/kworkflow.config ./
```

`kw` first read the global configuration from `~/.config/kw/etc/kworkflow.config`, next, it inpect the current directory to see it find a local configuration file. If it finds, it replace the values of each parameter based on the local file.

## Uninstall and update

We have two type of uninstall in `kw`:

1. Soft, parameter `--uninstall | -u`
2. Hard, parameter `--completely-remove`

The first approach is the recommend one, because it keeps some internal data managed by `kw` that you probably don't want to remove such as the `.config` files under the management of `kw`. However, if you are really sure about clean everything use `--completely-remove` and be aware of the consequences.

If you want to update `kw` you just need to do the following steps:
```
cd kworkflow
git pull
./setup -i
```

The command `./setup -i` will update the files that you already have installed.

# kw basic command

Now it is time to show some of the command that `kw` provide, for not make this post huge we will cover the first set of features provided by `kw`.

## Help

You have at least three easy way to get help from `kw` command:

1. `kw help`: This command will show a summary information on how to use some of the `kw` commands.
2. `kw man`: This command opens manual page with detailed description on how to use all the available commands.
3. Online documentation: you can see the online documentation at LINK. This documentation is generated from the files inside the `documentation` directory.

## Codestyle

One of the most common task during the engagement with Linux Kernel it is the use of checkpath for checking if your changes follows the codestyle guideline. One of the recommend way to work with checkpatch it is the use of git hooks, however, sometimes we just want to check a random code style or we don't want to wait until we commit our changes. For this reason, `kw` provide a handy tool named `codestyle` that checks a file, directory or patch; the simple way to use it can be seen below:

```
kw codestyle PATH/TO/[FILE|DIRECTORY]
kw c PATH/TO/[FILE|DIRECTORY]
```

Let's try a real-world experiment, first of all go to your kernel directory and try the following command:

```
kw c drivers/gpu/drm/amd/display/amdgpu_dm/
```

This command display all codestyle problems related with all files inside `amdgpu_dm` directory. You can try a single file with:

```
kw c drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_crc.c
```

## Maintainers

When we have a patch ready for submission to the community, we usually want to send it to the correct channels and maintainers. For helping with this task, Linux Kernel provide a script named `get_maintainers` and we have a wrapper for make the work with this script straightforward which is the option `maintainers`. The use of this tool is quite simple, see:

```
kw maintainers PATH/TO/[FILE|DIR]
```

In the Linux Kernel repository, try:

```
kw m drivers/gpu/drm/vkms
```

`m` is a shortcut for `maintainers`. We also provide a feature that attempt to provide the original author, you can use `--authors` or `-a`. See:

```
kw m -a drivers/gpu/drm/vkms # or
kw maintainers --authors drivers/gpu/drm/vkms/
```

## Explore

Search string pattern in the Linux Kernel or in the git log are two common tasks in the Linux Kernel, for this reason `kw` have an interesting feature named `explore`. This feature supports string search based on patterns; Under the hood, the explore feature is a wrapper for git grep in the `kw`, for using it is really simple:

```
kw explore "STRING" # or
kw e "STRING" /PATH/TO
```

For example, in your Kernel repository, try:

```
kw e amdgpu_bo_unref drivers/gpu/drm/amd/
kw e iio_dummy_evgen_get_regs
```

Notice that indicate the path in the end of the function is optional, if you do not specify anything `kw` will start to search from `./`. You can also use this feature for search strings with spaces, you just have to add quotes for it:

```
kw e "want, lalala"
```

Sometimes we want to find something in the git log, and `kw` is here for rescue! Try:

```
kw e --log "vertex and fragment"
```

## Variables

Finally, `kw` provide a feature for showing the variable values adopted used by it. Since we can have multiple `kworkflow.config`, see the values loaded by `kw` can be useful for identify an issue. For see it, just try:

```
kw vars # or kw v
```

## Conclusion

Here we introduced the basic features provided by `kw` and an overview on how it works; keep in mind that we still need to polish many of the features described here, for this reason patch and bug report are very welcome. In the next tutorials we will explore other features that deserve some extra attention. 
