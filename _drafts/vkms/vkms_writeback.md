---
layout: post
title:  "VKMS writeback anatomy"
date:   2020-07-12
author: siqueira
categories: "linux-kernel-basic"
lang: en
---

{% include add_ref.html id="wbpatchset"
    title="Introduce writeback connectors"
    year="2016/10/26"
    url="https://lwn.net/Articles/704647/" %}

A long time ago I started to work for adding writeback support on VKMS as a way to improve the usage possibility for VKMS. Unfortunately, this feature toke a long time to get merged due to my lack of consistency; anyway, now this feature is available on VKMS and now it is time to going in details in this feature.


## What is a Writeback Connector?

Before we start to take a look into some of the details related to the writeback inside VKMS, we first need to know the idea behind this sort of connectors. Let's start to understand about this type of connector by using the Figure 1 as a guide; from the figure, notice that I used ellipses for indicating any real hardware and rectangles for software blocks.

{% include image-post.html
  src="posts/vkms/writeback_connector.png"
  caption="Writeback overview" %}

The first part of the picture represents the default workflow, where the framebuffer attached to each plane is blended inside the CRTC. The CRTC output is associated to the encoder and finally the encoder is attached to any specific connector. Now, going back to the CRTC block in the figure and notice that we also connected the CRTC to a virtual encoder which is hooked up to a writeback connector; notice from the figure, that writeback connector is associated to the memory. Observe that the output from the CRTC is forked in two different paths, which means that the buffer in memory has the exactly same image sent to the real connector.

Notice that the above abstraction exposes the memory writeback available in some display controllers to the userspace. This feature provide a lot of interesting use case such as screen-recording, screenshots, wireless display, display cloning, memory-to-memory composition, testing, etc {% include cite.html id="wbpatchset" %}.

## Acknowledgments

I would like to thanks Melissa Wen for her detailed review. I really appreciate
you taking the time out to share your feedback.


## History

1. V1: Release

{% include print_bib.html %}
