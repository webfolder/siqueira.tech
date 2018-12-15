---
layout: post
title:  "GSoC Final Report"
date:   2018-08-13
categories: report
published: true
---

Nothing lasts forever, and this also applies for GSoC projects. In this report,
I tried to summarize my experience in the DRI community and my contributions.

## Recap the project idea

First, it is important to remember the main subject of my GSoC Project:

> The Kernel Mode-Setting (KMS) is a mechanism that enables a process to
command the kernel to set a mode (screen resolution, color depth, and rate)
which is in a range of values supported by graphics cards and the display
screen. Creating a Virtual KMS (VKMS) has benefits. First, it could be used for
testing; second, it can be valuable for running X or Wayland on a headless
machine enabling the use of GPU. This module is similar to VGEM, and in some
ways to VIRTIO. At the moment that VKMS gets mature enough, it will be used to
run i-g-t test cases and to automate userspace testing.

I heard about VKMS in the DRM TODO list and decided to apply for GSoC with this
project. A very talented developer from Saudi Arabia named Haneen Mohammed had
the same idea but applied to the Outreachy program. We worked together with the
desire to push as hard as we can the Virtual KMS.

## Overcome the steep learning curve

In my opinion, the main reason for the steep learning curve came from the lack
of background experience in how the graphics stack works. For example, when I
took operating system classes, I studied many things related to schedulers,
memory and disk management, and so forth; on the other hand, I had a 10000-foot
view of graphics systems. After long hours of studying and coding, I started to
understand better how things work. It is incredible all the progress and
advances that the DRI developers brought on the last few years! I wish that the
new versions of the Operating system books have a whole chapter for this
subject.

I still have problems to understand all the mechanisms available in the DRM;
however, now I feel confident on how to read the code/documentation and get
into the details of the DRM subsystem. I have plans to compile all the
knowledge acquired during the project in a series of blog posts.

## Contributions

During my work in the GSoC, I send my patches to the DRI mailing list and
constantly got feedback to improve my work; as a result, I rework most of my
patches. The natural and reliable way to track the contribution is by using
“git log --author="Rodrigo Siqueira" in one of the repositories below:

* For DRM patches: git://anongit.freedesktop.org/drm-misc
* For patches already applied to Torvalds branch: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
* For IGT patches: git://anongit.freedesktop.org/drm/igt-gpu-tools

In summary, follows the main patches that I got accepted:

* drm/vkms: Fix connector leak at the module removal
* drm/vkms: Add framebuffer and plane helpers
* drm/vkms: Add vblank events simulated by hrtimers
* drm/vkms: Add connectors helpers
* drm/vkms: Add dumb operations
* drm/vkms: Add extra information about vkms
* drm/vkms: Add basic CRTC initialization
* drm/vkms: Add mode_config initialization

We received two contributions from external people; I reviewed both patches:

* drm/vkms: Use new return type vm_fault_t
* drm/vkms: Fix the error handling in vkms_init()

I am using IGT to test VKMS, for this reason, I decided to send some
contributions to them. I sent a series of patches for fixing GCC warning:

* Fix comparison that always evaluates to false
* Avoid truncate string in __igt_lsof_fds
* Remove parameter aliases with another argument
* Move declaration to the top of the code
* Account for NULL character when using strncpy
* Make string commands dynamic allocate (waiting for review)
* Fix truncate string in the snprintf (waiting for review)

I also sent a patchset with the goal of adding support for forcing a specific
module to be used by IGT tests:

* Add support to force specific module load
* Increase the string size for a module name (waiting for review)
* Add support for forcing specific module (waiting for review)

As a miscellaneous contribution, I created a series of scripts to automate the
workflow of Linux Kernel development. This small project was based on a series
of scripts provided by my mentor, and I hope it can be useful for newcomers.
Follows the project link:

1. [Kworkflow](https://github.com/rodrigosiqueira/kworkflow)

## Work in Progress

I am glad to say that I accomplished all the tasks initially proposed and I did
much more. Now I am working to make VKMS work without vblank. This still a work
in progress but I am confident that I can finish it soon. Finally, it is
important to highlight that my GSoC participation will finish at the end of
August because I traveled for two weeks to join the debconf2018.

## __Now this is not the end. It is not even the beginning of the end. But it is, perhaps, the end of the beginning__ - Winston Churchill

GSoC gave me one thing that I was pursuing for a long time: a subsystem in the
Linux Kernel that I can be focused for years. I am delighted that I found a
place to be focused, and I will keep working on VKMS until It is finished.

Finally, the Brazilian government opened a call for encouraging free software
development, and I decided to apply the VKMS project. Last week, I received the
great news that I was selected in the first phase and now I am waiting for the
final results. If everything ends well for me, I will receive funding to work
for 5 months in the VKMS and DRM subsystem.

## My huge thanks to...

I received support from many people in the dri-devel channel and mailing list.
I want to thanks everybody for all the support and patience.

I want to thanks Daniel Vetter for all the feedback and assistance in the VKMS
work. I also want to thanks Gustavo Padovan for all the support that he
provided to me (which include some calls with great explanations about the
DRM). Finally, I want to thanks Haneen for all the help and great work.

## Reference

1. [Use new return type vm_fault_t](https://lkml.org/lkml/2018/7/26/549)
2. [Fix the error handling in vkms_init()](https://lkml.org/lkml/2018/8/2/951)
3. [Add support to force specific module load](https://www.spinics.net/lists/intel-gfx/msg170670.html)
