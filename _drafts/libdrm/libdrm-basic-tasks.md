---
layout: post
title:  "Libdrm Introduction"
date:   2020-02-05
categories: drm
---

{% include add_ref.html id="libdrm"
    title="DRM Software Architecture"
    date="2020-02-05"
    url="https://en.wikipedia.org/wiki/Direct_Rendering_Manager#Software_architecture" %}

{% include add_ref.html id="sampleDrmAvailable"
    title="Sample: Step 1: drmAvailable()"
    date="2020-02-05"
    url="https://gitlab.com/rodrigosiqueira/playground/-/blob/master/libdrm/basic/src/1_device_metadata.c#L19" %}


In this post we will start to play with Libdrm, here just introduce the elementary feature from this library.

# Overview

At this time, I can say that I started to contribute for DRM for a long time ago; however, one question always bug me:

> How the userspace interact with DRM subsystem?

I have to admit that my lack of comprehension of the userspace always bothered, I mean, I just want to have the base knowledge; unfortunately, I was always busy with a lot of different tasks and never got the opportunity to going deep on this field. However, the destine smile to me and gave me a great opportunity for learn this as part of my daily task in my job; basically, since the beginning of 2020 I had to dive into the `libdrm`. For those, that who doesn't know what is `libdrm` follows the Wikipedia explanation:

> A library called libdrm was created to facilitate the interface of user space
  programs with the DRM subsystem. This library is merely a wrapper that
  provides a function written in C for every ioctl of the DRM API, as well as
  constants, structures and other helper elements. The use of libdrm not only
  avoids exposing the kernel interface directly to user space, but presents the
  usual advantages of reusing and sharing code between programs.
  {% include cite.html id="libdrm" %}

Learn about `libdrm` wasn't an easy task, due to the lack of tutorials and documentation about this library; fortunately, I found a lot of brave people that wrote some stuff in their blogs about `libdrm`. Inspired by the lack of tutorials related to `libdrm` and based on my excitement to share everything that I learn I decided to write a series of tutorials about this amazing library. I'll try my best to share everything that I learned and I'll also try to add as much reference as possible.

Ok, for this post we will explore some elementary functions provided by `libdrm`. We will play with:
* Generic functions;
* Device manipulation;
* Collect some basic information about device.

# Prepare to work

Follows the description of my development system and my test system:

* Development system
  - ArchLinux
  - libdrm package
* Test system
  - QEMU VM and Raspberry pi
  - A driver that supports DRM
  - libdrm package

All the code discussed in this page can be accessed at:

LINK

I provide an automated compilation tool, however, if you are curious you can compile a code that uses `libdrm` with:

```
gcc -Wall YOUR_CODE.c -o YOUR_BINARY `pkg-config --libs --cflags libdrm`
```

# Checking for DRM support

`libdrm` provide an interesting function named `drmAvailable()`, here is the signature:

```
drm_public int drmAvailable(void)
```

This function try to open the primary device and if the device is available this function returns 1, otherwise returns 0. Using this function is straightforward and really useful, for this reason we start our sample code with the following code{% include cite.html id="sampleDrmAvailable" %}:

```
rc = drmAvailable();
if (!rc) {
  printf("Unfortunately, your system does not have DRM support\n");
  return 0;
}
```

With the above verification we can go ahead and call some of the `libdrm`.

# Get all DRM devices available in the system

`libdrm` provide a powerful function that allow us to retrieve all information about all devices:

```
drm_public int drmGetDevices(drmDevicePtr devices[], int max_devices)
```



```
total_dev = drmGetDevices(dev, MAX_CARDS_SUPPORTED);
if (total_dev < 0) {
        printf("Error: drmGetDevices: %s\n", strerror(total_dev));
        return total_dev;
}
printf("\t2. Total of devices available in your system: %d\n", total_dev);
```

{% include print_bib.html %}
