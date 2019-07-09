---
layout: post
title:  "Status Update, June 2019"
date:   2019-07-09
categories: status_update
published: true
---

{% include add_ref.html id="crcproblemFirst"
    title="First discussion in the Shayenne's patch about the CRC problem"
    url="https://lkml.org/lkml/2019/3/10/197" %}

{% include add_ref.html id="crcproblemSecond"
    title="Patch fix for the CRC issue"
    url="https://patchwork.freedesktop.org/patch/308617/" %}

{% include add_ref.html id="danielFixCRC"
    title="Daniel final fix for CRC"
    url="https://patchwork.freedesktop.org/patch/308881/?series=61703&rev=1" %}

{% include add_ref.html id="danielReworkCRC"
    title="Rework crc worker"
    url="https://patchwork.freedesktop.org/series/61737/" %}

{% include add_ref.html id="wbV1"
    title="Introduces writeback support"
    url="https://patchwork.freedesktop.org/series/61738/" %}

{% include add_ref.html id="configfs"
    title="Introduce basic support for configfs"
    url="https://patchwork.freedesktop.org/series/63010/" %}

{% include add_ref.html id="novblank"
    title="Change EINVAL by EOPNOTSUPP when vblank is not supported"
    url="https://patchwork.freedesktop.org/patch/314399/?series=50697&rev=7" %}

{% include add_ref.html id="novblankIGT"
    title="Skip VBlank tests in modules without VBlank"
    url="https://gitlab.freedesktop.org/drm/igt-gpu-tools/commit/2d244aed69165753f3adbbd6468db073dc1acf9a" %}

{% include add_ref.html id="igtWb"
    title="Add support for testing writeback connectors"
    url="https://patchwork.freedesktop.org/series/39229/" %}


For a long time, I'm cultivating the desire of getting the habit of writing
monthly status update; in some way, [Drew DeVault's Blog posts](https://drewdevault.com/)
and [Martin Peres](http://mupuf.org/blog/authors/mupuf/) advice leverage me
toward this direction. So, here I'm am! I decided to embrace the challenge of
composing a report per month. I hope this new habit helps me to improve my
write, summary, and communication skills; but most importantly, help me to keep
track of my work. I want to start this update by describing my work conditions
and then focus on the technical stuff.

The last two months, I have to face an infrastructure problem to work. I'm
dealing with obstacles such as restricted Internet access and long hours in
public transportation from my home to my workplace. Unfortunately, I cannot
work in my house due to the lack of space, and the best place to work it is a
public library at the University of Brasilia (UnB); go to UnB every day makes
me wast around 3h per day in a bus. The library has a great environment, but it
also has thousands of internet restrictions, for example, I cannot access
websites with '.me' domain and I cannot connect to my IRC bouncer. In summary:
It has been hard to work these days. So, let's stop to talk about non-technical
stuff and let's get to the heart of the matter.

I really like to work on VKMS, I know this isn't news to anyone, and in June
most of my efforts were dedicated to VKMS. One of my paramount endeavors it was
found and fixed a bug in vkms that makes `kms_cursor_crc`, and
`kms_pipe_crc_basic` fails; I was chasing this bug for a long time as can be
seen here {% include cite.html id="crcproblemFirst" %}. After many hours of
debugging I sent a patch for handling this issue {% include cite.html
id="crcproblemSecond" %}, however, after Daniel's review, I realize that my
patch does not correctly fix the problem. Daniel decided to dig into this issue
and find out the root of the problem and later sent a final fix; if you want to
see the solution, take a look at {% include cite.html id="danielFixCRC" %}. One
day, I want to write a post about this fix since it is an interesting subject
to discuss.

Daniel also noticed some concurrency problems in the CRC code and sent a
patchset composed of 10 patches that tackle the issue. These patches focused on
creating better framebuffers manipulation and avoiding race conditions; it took
me around 4 days to take a look and test this series. During my review, I asked
many things related to concurrency and other clarification about DRM, and
Daniel always replied with a very nice and detailed explanation. If you want to
learn a little bit more about locks, I recommend you to take a look at {%
include cite.html id="danielReworkCRC" %}; serious, it is really nice!

I also worked for adding the writeback support in vkms; since XDC2018 I could
not stop to think about the idea of adding writeback connector in vkms due to
the benefits it could bring, such as new test and assist developers with visual
output. As a result, I started some clumsy attempts to implement it in January;
but I really dove in this issue in the middle of April, and in June I was
focused on making it work. It was tough for me to implement these features due
to the following reasons:

1. There isn't i-g-t test for writeback in the main repository, I had to use a
   WIP patchset made by Brian and Liviu.
2. I was not familiar with framebuffer, connectors, and fancy manipulation.

As a result of the above limitations, I had to invest many hours reading the
documentation and the DRM/IGT code. In the end, I think that add writeback
connectors paid well for me since I feel much more comfortable with many things
related to DRM these days. The writeback support was not landed yet, however,
at this moment the patch is under review (V3) and changed a lot since the first
version; for details about this series take a look at {% include cite.html
id="wbV1" %}. I'll write a post about this feature after it gets merged.

After having the writeback connectors working in vkms, I felt so grateful to
Brian, Liviu, and Daniel for all the assistance they provided to me. In
particular, I was thrilled that Brian and Liviu made `kms_writeback` test which
worked as an implementation guideline for me; as a result, I update their
patchset for making it work in the latest version of IGT and made some tiny
fixes; my goal was helping them to upstream `kms_writeback`. I resubmit the
series with the hope to see it landed in the IGT {% include cite.html
id="igtWb" %}.

Parallel to my work with writeback, I was trying to figure out how could I
expose vkms configurations to the userspace via configfs. After many efforts, I
submitted the first version of configfs support; in this patchset I exposed the
virtual and writeback connectors. Take a look at {% include cite.html
id="configfs" %} for more information about this feature, and definitely, I'll
write a post about this feature after it gets landed.

Finally, I'm still trying to upstream a patch that makes
`drm_wait_vblank_ioctl` return EOPNOTSUPP instead of EINVAL if the driver does
not support vblank get landed.  Since this change is in the DRM core and also
change the userspace, it is not easy to make this patch get landed. For the
details about this patch, you can take a look here
{% include cite.html id="novblank" %}. I also implemented some changes in the
`kms_flip` to validate the changes that I made in the function
`drm_wait_vblank_ioctl` and it got landed
{% include cite.html id="novblankIGT" %}.

## July Aims

In June I was totally dedicated to vkms, now I want to slow my road a little
bit and study more about userspace. I want to take a step back and make some
tiny programs using libdrm with the goal to understand the interaction among
userspace and kernel space. I also want to take a look at the theoretical part
related to computer graphics.

I want to put some effort to improve a tool named
[kw](https://github.com/rodrigosiqueira/kworkflow) that help me during my work
with Linux Kernel. I also want to take a look at real overlay planes support in
vkms. I noted that I have to find a "contribution protocol" (review/write code)
that works for me in my current work conditions; otherwise, work will become
painful for my relatives and me. Finally, and most importantly, I want to take
some days off to enjoy my family.

**Info:**
If you find any problem with this text, please let me know. I will be glad to
fix it.
{: .info}

{% include print_bib.html %}
