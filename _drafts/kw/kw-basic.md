---
layout: post
title: "kw: a tool for supporting kernel developers"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

{% include add_ref.html id="kwbranches"
    title="Development Cycle and Branches"
    date="2020-05-08"
    url="https://siqueira.tech/doc/kw/content/howtocontribute.html#development-cycle-and-branches" %}

This is the first installment page that will describe a tool named Kernel
Workflow, or just kworkflow or kw.

# Command summary

**If you did not read this tutorial yet, skip this section. I added this
section as a summary for someone that already read this tutorial and just want
to remember a specific command.**
{: .info-box}

&rarr; Setup script:

```bash
./setup --install # or just ./setup -i
./setup --uninstall # or just ./setup -u
./setup --completely-remove
```

&rarr; Basic commands:

```bash
kw version
kw init
kw c PATH/TO/[FILE|DIRECTORY] # or kw codestyle PATH/TO/[FILE|DIRECTORY]
kw m PATH/TO/[FILE|DIRECTORY] # or kw maintainers PATH/TO/[FILE|DIRECTORY]
kw e "STRING" /PATH/TO # or kw explore "STRING" /PATH/TO
kw vars # or kw v
```

# First things first, what is it kw?

`kw` stands for Kernel Workflow, and it is a tool that aims for backing Linux
kernel developers by automating some of their daily tasks. `kw` currently
support:

1. Handle kernel code style and maintainers;
2. Manage `.config` files;
3. Support with ssh command;
4. Build management;
5. Operate deploys of new kernel or module version;
6. Handle QEMU virtual machine;
7. Generate usage statistics;
8. Support basic drm features.

We have plans to add other functionalities, for example, we want to add support
for maintainers tasks (inspired by `dim`). Additionally, if our community
grows, we want to support a large variate of distros and bootloaders.

# Why I started it?

Back to 2018 I was preparing for
applying to Google Summer of Code (GSoC). At that moment, I was learning
basic stuff such as how to compile and install a new kernel version in a target
machine; after I repeated these tasks dozens of time, I naturally started to
write some simple shell scripts for automating these repeatable tasks. After I got
accepted in the GSoC program, [Gustava Padovan](https://padovan.org/) (one of
my mentors) introduced me to his set of [scripts for working](https://github.com/padovan/scripts) with the kernel. After use
Padovan's scripts, I started to improve it by fixing bugs and adding new
functionalities, later I decided to start a project that unifies other people's
scripts in a single tool. I did it, because I realize that many kernel developers create their
own tool, so, why not put all of this together in a single tool and share
maintenance effort?

# Who are involved?

`kw` emerged as a side project in the GSoC internship and I also tried to
spread it between students from my home university, as a result, most of the
contributors came from the University of Sao Paulo (USP). In particular,
[Matheus Tavares](https://matheustavares.gitlab.io/) started to contribute to
`kw` during his graduation, and since that he kept advancing `kw` features;
nowadays, he is one of the `kw` maintainers.

# Our philosophy

Mainly, `kw` is developed and maintained by
[Matheus Tavares](https://matheustavares.gitlab.io/) and I. It is important to
highlight that we got cultural and technical influence from `git` and Linux
kernel community. For the sake of brevity, I'll list our `kw` philosophy:

- We got inspiration on the way that `git` project organize their features, for
  example, we try to imitate how `git` handle its commands;
- We embrace unit tests;
- We embody document as a part of `kw` philosophy;
- We try to keep the required dependencies to the minimum. We favor to adopt
  tools that can be easily found in most of the people environment;
- We try our best to have a stable version of `kw`, however, we also keep a
  bleeding-edge version in the unstable branch {% include cite.html id="kwbranches" %};

# How to install

It is very simple to install `kw` from the repository, you just need to follow
these steps:

0. If you use Debian or Arch system based, the setup script will handle the package dependencies. Anyway, the following software needs to be installed (not all of them are mandatory):

```bash
libguestfs qemu bash git python-docutils paplay notify-send
```

1. Get `kw` source code:

```bash
git clone https://github.com/kworkflow/kworkflow.git
```

2. Inside kworkflow directory, execute the following command:

```bash
./setup --install # or just ./setup -i
```

3. Reload your bashrc:

```bash
source ~/.barshrc
```

4. Test your installation with the command:

```bash
kw version
```

If you want to use the latest version of kw, you need to change to the unstable branch and execute the `setup -i` command again.

## Kw files path

`kw` will create a small set of directories in your home, take a look at:

```bash
ls ~/.local/bin # kw executable
ls ~/.local/lib/kw/ # kw main files
ls ~/.local/lib/etc/ # kw global configuration
ls ~/.local/share/ # other kw related files
ls ~/.kw # kw data generated during its usage
```

Take a few minutes to inspect all aforementioned directories for getting a
better view of the code organization. Additionally, open your `~/.bashrc` to
check a line added by the setup.

## Configuration file

Inspired by `git` we use a global and local configuration file, you can see
this configuration file in the directory:

```bash
~/.local/etc/kw/kworkflow.config
```

Take a few minutes to read this file, it has comments for each parameter.

`kw` also support local configuration file per kernel project, you just need a
`kworkflow.config` in the local directory that you're working on. For example:

```bash
git clone https://anongit.freedesktop.org/git/drm/drm-misc.git
cd drm-misc
kw init
```

`kw` first read the global configuration from
`~/.config/kw/etc/kworkflow.config`, next, it checks if the user has a local
configuration in the current directory. If the user has it, `kw` going to
replace the values of each parameter based on the local file.

> If you are familiar with `git config`, keep in mind that `kw` follows the
> same patterns. 
{: .info-box}

## Uninstall and update

We have two mechanisms for uninstalling `kw`:

1. **Soft uninstall**: `--uninstall | -u`;
2. **Hard uninstall**: `--completely-remove`;

The first approach is the recommended one, it removes all `kw` files and
changes in your `.bashrc` but it still keeps some internal data managed by `kw`
that you probably don't want to remove such as all `.config` files under `kw`
management. However, if you are really sure about clean everything use
`--completely-remove` and be aware that all `kw` data going to be wiped out
from your system.

If you want to update `kw` you just need to use:

```bash
cd kworkflow
git pull # git checkout unstable
./setup -i
```

The command `./setup -i` updates the files that you already have installed.

# kw basic command

In the final part of this post I'm going to introduce some basic `kw` command,
and I'll let other interesting features for another post.

## Help

You have three easy ways to get help from `kw` command:

1. `kw help`: It shows a summary on how to use some of the `kw` commands;
2. `kw man`: This command opens a manual page with detailed description on how
   to use all the available commands;
3. Online documentation: you can see the online documentation in the
   [link](https://siqueira.tech/doc/kw/).

## Codestyle

Code style verification is one of the most common task in the Linux Kernel
development, this verifications is simplified by a tool named `checkpatch`.
`kw` provides a handy tool named `codestyle`, or just `c`, that checks a file,
directory or patch; the simple way to use it can be seen below:

```bash
kw codestyle PATH/TO/[FILE|DIRECTORY]
kw c PATH/TO/[FILE|DIRECTORY]
```

Let's try a practical experiment, first of all, go to your kernel directory and
try the following command:

```bash
kw c drivers/gpu/drm/amd/display/amdgpu_dm/
```

This command display all codestyle problems related to all files inside
`amdgpu_dm` directory. You can try a single file with:

```bash
kw c drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm_crc.c
```

## Maintainers

When we have a patch for submitting to the community, we usually want to send
it to the correct channels and maintainers for increasing the chance of getting
a review. Linux Kernel provides a script named `get_maintainers` where `kw`
added a wrapper for it in order to make its usage straightforwardly. For
getting the maintainers information with `kw` you can use `maintainers` or `m` option; for example:

```bash
kw maintainers PATH/TO/[FILE|DIR]
```

In the Linux Kernel repository, try:

```bash
kw m drivers/gpu/drm/vkms
```

The `m` option is a shortcut for `maintainers`. If you want to get the original
author, you can use `--authors` or `-a`. See:

```bash
kw m -a drivers/gpu/drm/vkms # or
kw maintainers --authors drivers/gpu/drm/vkms/
```

## Explore

Search for string pattern in the Linux Kernel or in the git log are two common
tasks, for this reason `kw` has a feature named `explore`. This feature
supports string search based on patterns; under the hood, the explore feature
is a wrapper for `git grep` and `gnu grep`, see the example below on how to use this option:

```bash
kw explore "STRING" # or
kw e "STRING" /PATH/TO
```

For example, in your Kernel repository, try:

```bash
kw e amdgpu_bo_unref drivers/gpu/drm/amd/
kw e iio_dummy_evgen_get_regs
```

From the above example, you can notice that the path at the end of the function
is optional; if you do not specify anything `kw` will start to search from
`./`. You can also use this feature for search strings with spaces, you just
have to add quotes for it:

```bash
kw e "want, lalala"
```

Sometimes we want to find something in the git log, and `kw` is here for
the rescue! Try:

```
kw e --log "vertex and fragment"
```

## Variables

As previously described we can have a local and global config file, for this
reason, we have a tool that shows the value of the config variables used by
`kw`:

```
kw vars # or kw v
```

# About `kworkflow.config`

TODO

## Conclusion

Here I introduced a very basic set of features provided by `kw` and an overview on how
to use them; keep in mind that we still need to polish many of the features
described here, thus patch and bug report are very welcome. In the
next post, we will explore other features that deserve some extra attention.
