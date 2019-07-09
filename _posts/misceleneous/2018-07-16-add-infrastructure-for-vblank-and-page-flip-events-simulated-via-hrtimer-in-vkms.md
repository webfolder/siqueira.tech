---
layout: post
title:  "Add infrastructure for Vblank and page flip events in vkms simulated by hrtimer"
date:   2018-07-16
categories: misceleneous
published: true
---

Since the beginning of May 2018, I have been diving into the DRM subsystem. In
the beginning, nothing made sense to me, and I had to fight hard to understand
how things work. Fortunately, I was not alone, and I had great support from
Gustavo Padovan, Daniel Vetter, Haneen Mohammed, and the entire community.
Recently, I finally delivered a new feature for VKMS: the infrastructure for
Vblank and page flip events.

At this moment, VKMS have regular Vblank events simulated through hrtimers (see
drm-misc-next), which is a feature required by VKMS to mimic real hardware [6].
The development approach was entirely driven by the tests provided by IGT, more
specifically the kms_flip. I modified IGT to read a module name via command
line and force the use of it, instead of using only the modules defined in the
code (patch submitted to IGT, see [1]). With this modification in the IGT, my
development process to add a Vblank infrastructure to VKMS had three main steps
as Figure 1 describes.

{% include image-post.html
  src="posts/tdd-drm.png"
  caption="My work cycle in VKMS" %}

Firstly, I focused only on the subtest  "basic-plain-flip" from IGT and after
each execution of the test I checked the failure messages. Secondly, I tried to
write the required code to make the test pass; it is essential to highlight
that this phase sometimes took me days to understand the problem and implement
the fix. Finally, after I overcome the failure, I just put an additional effort
to improve the implementation. As can be seen in the patchset send to add the
Vblank support [2], the first set of patches was not directly related to the
Vblank itself, but it was a necessary infrastructure required for kms_flip to
work.

{% include image-post.html
  src="posts/basic-plain-flip_passing.png"
  caption="sudo ./tests/kms_flip  --run-subtest basic-plain-flip --force-module vkms" %}

After an extended period of work to make VKMS pass in the basic-plain-flip, I
finally achieved it thanks to all the support that I received from the DRM
community. Next, I started to work on the subtest "wf_vblank-ts-check", and
here I spent a lot of time debugging problems. My issue here was due to the
stochastic test behavior, sometimes it passed and other, it fails, and I
supposed the problem was related to the accumulation of errors during the page
flip step. As a result, I put a considerable effort to make the timer in the
page flip precise, I end up with a patch that calculates the exact moment for
the next period (see [5]). Nevertheless, after I submitted the patch, Chris
Wilson highlighted that I was reinventing the wheel since hrtimer already did
the required calculations [4]; he was 100% right, after his comment I looked
line by line of hrtimer_forward, and I concluded that I implemented the same
algorithm. I lost some days recreating something that is not useful in the end;
however, it was really valuable for me since I learned how hrtimer works and
also expanded my comprehension about Vblank. Finally, Daniel Vetter precisely
pointed out a series of problems in the patch (see [3]) that not only improved
the tests, but also made most of the tests in the kms_flip pass.

In conclusion, adding the infrastructure for Vblank and page flip events in
vkms was an exciting feature for VKMS, but also it was an important task to
teach me how things work in the DRM. I am still focused on this part of the
VKMS, but now, I am starting to think how can I add virtual hardware which does
not support Vblank interrupt. Finally, I want to write a detailed blog post on
how I implemented the Vblank support in the VKMS and another post about timers
(users and kernel space); I believe this sort of post could be helpful for
someone that is just starting in the DRM subsystem.

Thanks for all the DRM community that is always kind and provide great help for
a newcomer like me :)


## Reference

1. [Force option in IGT](https://www.spinics.net/lists/intel-gfx/msg170670.html)
2. [Adding infrastructure for Vblank and page flip events in vkms](https://www.spinics.net/lists/dri-devel/msg182903.html)
3. [Daniel Vetter comments in V2](https://www.spinics.net/lists/dri-devel/msg182042.html)
4. [Chris Wilson comments about hrtimer](https://www.spinics.net/lists/dri-devel/msg182043.html)
5. [Calculating the period](https://www.spinics.net/lists/dri-devel/msg182037.html)
6. [DRM misc-next](https://cgit.freedesktop.org/drm/drm-misc/)
