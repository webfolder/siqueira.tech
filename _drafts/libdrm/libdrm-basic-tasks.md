---
layout: post
title:  "Part 1: Libdrm Introduction"
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

`libdrm` provide a powerful function that allow us to retrieve a lot of information about all the available devices:

```
drm_public int drmGetDevices(drmDevicePtr devices[], int max_devices)
```

This function expects two parameters:
1. **devices[]**: this parameter expects an array of `drmDevicePtr` which will be populate inside `drmGetDevices()`; each element in the array has the device information. If you want to check the total of devices first, you can set this parameter as NULL and the function will give you the total number of devices available in your system.
2. **max_devices**: Total of device information that you want to retrieve.

For trying to illustrate the use of this function in a real code, take a look at the below code snippet:

```
drmDevicePtr dev[MAX_CARDS_SUPPORTED];
[..]
total_dev = drmGetDevices(dev, MAX_CARDS_SUPPORTED);
if (total_dev < 0) {
        printf("Error: drmGetDevices: %s\n", strerror(total_dev));
        return total_dev;
}
printf("\t2. Total of devices available in your system: %d\n", total_dev);
```

For trying to better understand the value of this function, let's take a look at `_drmDevice` struct:

```
typedef struct _drmDevice {
    char **nodes;
    int available_nodes;
    int bustype;
    union {
        drmPciBusInfoPtr pci;
        drmUsbBusInfoPtr usb;
        drmPlatformBusInfoPtr platform;
        drmHost1xBusInfoPtr host1x;
    } businfo;
    union {
        drmPciDeviceInfoPtr pci;
        drmUsbDeviceInfoPtr usb;
        drmPlatformDeviceInfoPtr platform;
        drmHost1xDeviceInfoPtr host1x;
    } deviceinfo;
} drmDevice, *drmDevicePtr;
```

The first interesting parameter it is the `bustype`, which can be:

* `DRM_BUS_PCI`: Your device uses PCI bus;
* `DRM_BUS_USB`: TODO
* `DRM_BUS_PLATFORM`: TODO
* `DRM_BUS_HOST1X`: TODO

You need to know witch bus your system is using in order to retrieve the correct data from the subsequent fields in `_drmDevice`. For the sake of simplicity, let's suppose that your system uses PCI and based on that we can take a look at `drmPciBusInfoPtr`:

```
typedef struct _drmPciBusInfo {
    uint16_t domain;
    uint8_t bus;
    uint8_t dev;
    uint8_t func;
} drmPciBusInfo, *drmPciBusInfoPtr;$
```

In summary, the above struct keeps the PCI information about the device bus. We can also take the device information, by retrieve the data in the `deviceinfo` field from `_drmDevice`; this field provide the following information:

```
typedef struct _drmPciDeviceInfo {
    uint16_t vendor_id;
    uint16_t device_id;
    uint16_t subvendor_id;
    uint16_t subdevice_id;
    uint8_t revision_id;
} drmPciDeviceInfo, *drmPciDeviceInfoPtr;
```

Note that we can capture a lot of vendor specific information such as the vendor id. Ok, after take a look on all of these data let's take a look on how our sample code should looks like now:

```
printf("\t 2.1 Device details\n");
for (int i = 0; i < total_dev; i++) {
        printf("\t\t Device: %d\n", i);

        if (dev[i]->bustype == DRM_BUS_PCI) {
                printf("\t\t PCI BUS:\n");
                printf("\t\t  Bus info\n");
                printf("\t\t  domain: %04x\n", dev[i]->businfo.pci->domain);
                printf("\t\t  bus: %02x\n", dev[i]->businfo.pci->bus);
                printf("\t\t  function: %01x\n", dev[i]->businfo.pci->func);
                printf("\t\t Device Info\n");
                printf("\t\t  vendor_id: %04x\n", dev[i]->deviceinfo.pci->vendor_id);
                printf("\t\t  device_id: %04x\n", dev[i]->deviceinfo.pci->device_id);
                printf("\t\t  subvendor_id: %04x\n", dev[i]->deviceinfo.pci->subvendor_id);
                printf("\t\t  subdevice_id: %04x\n", dev[i]->deviceinfo.pci->subdevice_id);
                printf("\t\t  revision_id: %02x\n", dev[i]->deviceinfo.pci->revision_id);
        }
}

drmFreeDevices(dev, total_dev);
```

Just notice that we have to free the list of devices when we finish with it.

# Get Version Information

Now it is time to open our device and explore a little bit more about the version information associated to it. Our first step, should be open the device which is straightforward:

```
fd = open("/dev/card0", O_RDWR | O_NONBLOCK);
if (fd < 0) {
  printf("WARN: Something went wrong when we tried to open %s\n", path);
  continue;
}
```

Now that we have the file descriptor, we can use:

```
drm_public drmVersionPtr drmGetVersion(int fd)
```

This function expects a valid file descriptor and returns a `drmVersionPtr` if everything ends well. Take a look on `drmVersionPtr`:

```
typedef struct _drmVersion {
    int     version_major;
    int     version_minor;
    int     version_patchlevel;
    int     name_len;
    char    *name;
    int     date_len;
    char    *date;
    int     desc_len;
    char    *desc;
} drmVersion, *drmVersionPtr;
```

All the field described in the `_drmVersion` struct describes the hardware information, I believe that is not required to explain each field since their names make their meaning evident. Now, we can print the version information with the below code:

```
version = drmGetVersion(fd[i]);
if (!version) {
        printf("WARN: We could not retrieve device version\n");
        goto clean;
}

printf("\t\t Major and Minor version: %d:%d\n", version->version_major, version->version_minor);$
printf("\t\t Name: %s\n", version->name);
printf("\t\t Date: %s\n", version->date);
printf("\t\t Description: %s\n", version->desc);

drmFreeVersion(version);
```

# Conclusion

At this post intention was make you a little bit more familiar with `libdrm`, however, we barely scratch the its surface. For the next post we will keep our focus on getting system information via `libdrm`, but more focused on the Direct Rendering Management (DRM) elements.

{% include print_bib.html %}
