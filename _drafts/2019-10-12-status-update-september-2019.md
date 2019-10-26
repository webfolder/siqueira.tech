---
layout: post
title: "Status Update and XDC 2019, October 2019"
date: 2019-10-12
categories: status_update
published: true
---

{% include add_ref.html id="xdcsite"
    title="First discussion in the Shayenne's patch about the CRC problem"
    url="https://xdc2019.x.org" %}

{% include add_ref.html id="wbV1"
    title="Introduces writeback support"
    url="https://patchwork.freedesktop.org/series/61738/" %}

{% include add_ref.html id="freesync"
    title="FreeSync"
    url="https://en.wikipedia.org/wiki/FreeSync" %}

It has been a while since my last post, but there is a simple reason for that:
on August 5th, I had to move from Brazil to Canada. Why did I move? Thanks to
Harry Wentland, I got hired by AMD for working on the display team; from now
on, I suppose that I'll be around the DRM subsystem for a long time.

I have a few updates about my work with the community since I have been busy
with my relocation and adaptation; however, my main updates came from XDC 2019
{% include cite.html id="xdcsite" %}, and I want to share it here.

## XDC 2019 -  Montréal (Concordia University Conference)

This year I had the great luck of join XDC once again; however, at this time, I
was with Harry Wentland, Nicholas Kazlauskas, and Leo Li (we work together at
AMD). We put effort into learning with other people's experiences, and we also
tried to know what the compositor developers want to see in our driver. We also
used this opportunity to try to explain a little bit more about our hardware
features. In particular, we had conversations about Freesync, MST, DKMS, and so
forth; with this in mind, I'll share my view of the most exciting moments that
we had.

### VKMS

As usual, I tried my best to understand what people want to see in VKMS soon or
later;  for example, from the XDC 2018, I focused on fix some bugs but mainly
in add writeback support since it could provide a visual output (this work is
almost done, see {% include cite.html id="wbV1" %}). For this year, I collected
feedback from multiple people (special thanks to Marten, Lyude, Hiler, and
Harry), and from these conversations, I want to work in the following tasks:

1. Finish the writeback feature and enable visual output;
2. Add support for adaptive refresh rate;
3. Add support for "dynamic connectors", which can enable the MST test.

Martin Peres gave a talk that he shared his views for the CI and test. In his
presentation, he suggested to use VKMS to validate the API, and I have to admit
that I'm really excited about this idea. I hope that I can help with this.

## Freesync

The `amdgpu` drivers support a technology named Freesync
{% include cite.html id="freesync" %}. In a few words, this feature allows the
dynamic change of the refreshes rate, which can bring benefits for games and
also for power saving. Harry Wayland gave a talk about this feature, and you
can see it here:

  {% include youtube-player.html
    id="HYa4UvVtMOE?t=30120"
    caption="Video 1: Freesync, Adaptive Sync & VRR" %}

After Harry's presentation, many people asked interesting questions related to
this subject, this situation caught my attention, and for this reason, I added
the VRR to my roadmap in the VKMS. Roman Gilg, from KDE, was one of the
developers that asked for a protocol extension in Wayland for support Freesync;
additionally, compositor developers asked for mechanisms that enable them to
know in advance if the experience of a specific panel will be good or not.
Finally, there were some discussions about the use of Freesync for power saving
and also in an application that requires time-sensitive.

## IGT and CI

This year I kept my tradition of asking thousands of questions to Hiler to
learn more about IGT, and as usual, he was extremely kind and gentle with my
questions (thanks Hiler). One of the concepts that Hiler explained to me, it is
the use of `podman` (https://podman.io/) for prepare IGT image, for example,
after a few minutes of code pair with him I could run IGT on my machine after
executing the following commands:

```
sudo su
podman run --privileged registry.freedesktop.org/drm/igt-gpu-tools/igt:master
podman run --privileged registry.freedesktop.org/drm/igt-gpu-tools/igt:master \
                        igt_runner -t core_auth
podman run --privileged registry.freedesktop.org/drm/igt-gpu-tools/igt:master \
                        igt_runner -t core_auth /tmp
podman run --privileged -v /tmp/results:/results \
  registry.freedesktop.org/drm/igt-gpu-tools/igt:master igt_runner -t core_auth /results
```

We also had a chance to discuss CI with Martin Peres, and he explained his work
for improving the way that the CI keep track of the bugs. In particular, he
introduced a fantastic tool named `cibuglog` which is responsible for keep
tracking of test failures and using this data for building a database. Cibuglog
has a lot of helpful filters that enable us to see test problems associated
with a specific machine and bugs in the Bugzilla. Thanks Martin, for showing us
this amazing tool.

## Updates

I just want to finish this post with brief updates from my work with free
software, starting with `kw` and finish with VKMS.

## Kernel Workflow (`kw`)

When I started to work with VKMS, I wrote a tool named `kworkflow`, or simply
`kw`, for helping me with basic tasks related to Kernel development. These days
`kw` reborn to me since I was looking for a way to automate my work with
`amdgpu`; as a result, I implemented the following features:

- Kernel deploy in a target machine (any machine reachable via IP);
- Module deploy;
- Capture `.config` file from a target machine;

Unfortunately, the code is not ready for merging in the main branch, I'm
working on it; I think that in a couple of weeks, I can release a new version
with these features. If you want to know a little bit more about `kw` take a
look at https://siqueira.tech/doc/kw/

## VKMS

I was not working in VKMS due to my change of country; however, now I'm
reworking part of the IGT test related to writeback, and as soon as I finish
it, I'll try to upstream it again. I hope that I can also have the VKMS
writeback merged into the `drm-misc-next` by the end of this month. Finally, I
merged the prime supported implemented by Oleg Vasilev (huge thanks!).

## Conclusions

{% include print_bib.html %}
