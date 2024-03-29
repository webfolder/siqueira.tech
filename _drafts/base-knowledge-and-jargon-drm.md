---
layout: post
title:  "Establishing the Necessary Knowledge and Jargon"
date:   2018-07-13
categories: drm
---

{% include add_ref.html id="dedicatedGPU"
    title="Dedicated graphics cards"
    url="https://en.wikipedia.org/wiki/Graphics_processing_unit#Dedicated_graphics_cards" %}

{% include add_ref.html id="integrated"
    title="Integrated graphics processing unit"
    url="https://en.wikipedia.org/wiki/Graphics_processing_unit#Integrated_graphics_processing_unit" %}

{% include add_ref.html id="patterson"
    title="Computer Organization and Design MIPS Edition: The Hardware/Software Interface"
    author="DA Patterson, JL Hennessy"  %}

{% include add_ref.html id="refreshRate"
    title="Refresh rate"
    url="https://en.wikipedia.org/wiki/Refresh_rate" %}

{% include add_ref.html id="ldd"
    title="Linux Device Drivers"
    author="Jonathan Corbet, Alessandro Rubini, and Greg Kroah-Hartman"
    url="https://static.lwn.net/images/pdf/LDD3/ch01.pdf" %}

When I started to dive into the Direct Rendering Manager (DRM) subsystem, I had
to cope with my complete absence of knowledge in the graphics area; in
parallel, I had the challenge of helping to create a new driver named Virtual
Kernel Mode-Setting (VKMS) as my GSoC project. Due to my lack of know-how, I
had to read the documentation over and over. I really recommend any newcomer to do the same
because the DRM documentation is fantastic. Despite the amazing DRM
documentation, I had a hard time for understanding it, and the reasons were simple:
I did not have the required knowledge, and I did not understand the basic
jargon. Inspired by that, I decided to write this post for helping newcomers to
appreciate the DRM subsystem documentation.

**Help me to improve this text: This tutorial may have errors or some confusing
parts. If you find any problem or have a suggestion to improve this text,
please mail me with your ideas; I will try my best to embody your suggestions.
Finally, Most of the content described in this post came from multiple sources,
and I did my best to refer all of them; If I missed something, please, let me
know;**
{: .info-box}


 z-order



# Some Very Basic Concepts

Before we look at the DRM subsystem, it is crucial to acquire some general
knowledge about graphics; this subject is vast, because of this I'm only going
to highlight the essential concepts to understand the DRM documentation.

## Multiple Graphic Devices Management

During your journey into the DRM documentation, you'll continuously come across
two expressions: **Integrated Graphics (APU)** and **Dedicated Graphics (dGPU)**. Without
further ado, here is the meaning of each one:

* **Dedicated Graphics Card (or Discrete Graphics)**: This kind of device has
 many processing units, dedicated memory, and other units. Radeon 5700 XT and
 5500 are examples of this sort of devices. {% include cite.html id="dedicatedGPU" %}
* **Integrated Graphics (or Shared Graphic Solution - Integrated Graphics
 Processor - Accelerated Processing Unit)**: Usually, this sort of processor has
 less processing unit (when compared with dGPU), and the memory is shared with
the system. You can find this sort of GPU in the AMD (`amdgpu`), Intel
(`i915`),  and ARM (`mali`) processors. {% include cite.html id="integrated" %}
{: .definition-box}

Probably, you already noticed that both devices are not mutually exclusive,
i.e., we can find dGPU Card and an APU in the same
computer. These sort of machine usually have a mechanism for **GPU Switching**,
that rchestrates the use of multiple GPUs; switching between GPUS is
really convenient for saving energy, especially in mobile and laptop devices.

## Framebuffer

When you start to read about graphics, you will come across with the notorious word
"framebuffer", and here you will not find any precise definition about it
since it may vary accordingly with the context. When you read or see any code
related to framebuffer I recommend you to ask yourself: Is this a low-level or
high-level code? This question may help you to understand the level of details
relied on the idea of the framebuffer in your context. Nevertheless, I can take
the risk of trying to define a framebuffer based on the David Patterson
definition {% include cite.html id="patterson" %}:

A **Framebuffer** is a memory portion responsible for storing the bitmap to be
displayed; in other words, the image saved in the memory to be displayed in the
screen. The framebuffer usually has metadata, such as the bit pattern and the
refresh rate, related to the hardware constraints and the software. Modern
devices have dedicated hardware for handling the framebuffer and convert them
directly to a video signal.
{: .definition-box}

{% include image-post.html
  src="underConstruction_a2c.png"
  caption="a view of framebuffer, image based on" %}

## Display mode

Typically, when we talk about graphics devices, we have a set of properties
attached to it. An interesting device attribute is the **operation mode** which
specifies how the framebuffer should act. The combination of three elements
defines a mode:

1. **Screen Resolution (or display resolution)**: It is the number of pixels
   that can be shown in each dimension; usually, it is provided by “width X
   height” in pixel units. The resolution refers to the pixel density, which is
   the number of pixel per unit of distance or area.
  {% include image-post.html
    src="underConstruction_a2c.png"
    caption="Diagram illustrating different resolutions" %}
2. **Color Depth (or bit depth)**: It is the number of bits used to describe a
   single pixel color in a framebuffer. Take a look at Figure 2 to get a
   practical idea of this concept.
  {% include image-post.html
    src="posts/color_deph_comp-min.png"
    caption="Color depth of 256, 128, 16, 4, and 2 bits (right to left)" %}
3. **Refresh Rate (or vertical refresh rate)**: It is the number of times in a
   second that a display hardware updates its buffer {% include cite.html
   id="refreshRate" %}. Take a look at Video 1 to see how different refresh rate
   affects the image displayed by the monitor. A high refresh rate means a short
   time for updating its buffers; for example, a refresh rate of 60Hz update the
   buffer around ~0.01666 per second, and 120Hz updates the buffer around ~0.00833
   per second. Take care to not mix the concept of Frame Per Second (FPS) and
   Refresh Rate, former refers to the number of frames the device can produce, and
   the latter it is how many times the buffers are updated by the display.

  {% include youtube-player.html
    id="Q1cmhZs1P54?start=3"
    caption="Video 1: Slow motion Monitor refresh rates" %}

## Vertical Blanking Interval and Vertical Blank Interrupt

At my first interactions with the DRM documentation, I thought that Vertical Blanking Interval and Vertical Blank Interrupt are the same thing; however, there is a subtle difference between them:

* **Vertical Blanking Interval**: It is the time between the last frame line and the beginning of the first line of the next frame.
* **Vertical Blank Interrupt**: It is a feature find in some hardware, but not restricted to it, that generates signals when the display image has completely displayed and the screen could return to the start of the display.
{: .notice_warning}

Vblank work as a synchronization mechanism to inform via signal when a new image can be used. It is nice if the graphic device that generate the images is synchronized with display refresh rate, if they not match it can generate a problem named "Screen tearging". See Video 2 to see an example of the screen tearing problem. Finally, keep in mind that during the vblank interval it is really convenient to perform video operations.

  {% include youtube-player.html
    id="jVAFuUAKPMc"
    caption="Video 2: Example of tearing in a game" %}

## Page-Flipping (Double Buffer)

Before we take a look at the page-flipping concept, take a look to the Figure 4. In this picture you can see the representation of two different sides, one that represents the graphics been generated and the other representing the screen. At the first part of the image the screen display the buffer content, while the graphics produces a new content in the second buffer; both buffers are able to be displayed in the screen. When the monitor send the signal that the first image was completely displayed at the screen, the graphic card change the image pointer for the new image and then the screen start to render the new image. Afterward, the graphic card start to produce the new image and this process keep going.

  {% include image-post.html
    src="posts/graphics/page-flip.png"
    caption="Page-Flip example" %}

This example show how page-flip works. It is important to highlight that both buffers are able to be displayed, but at some point on buffer is enabled and the other not.

## Compositing Window Manager

This subject represents an huge area, and here I just want to provide a top view of the subject to support someone that will read the DRM documentation. In this sense, we start with a brief explanation of Compositing:

**Compositing**
is the combination of multiple image into a single one with the goal to offer the illusion that all elements are the same in the scene. All the compositing requires the replacement of one part of the image by another and some software manage this replacement.
{: .definition-box}

A **compositing window manager** provide buffers for the applications to drawn their own window. The window manager take all the application buffer together in a single buffer to produce the final image to be written in the screen. Note that the manager can make the operation of scaling, duplicating, rotating, blurring, 3D effects, and others. Figure 4, provide an overview of the Compositing window work.

  {% include image-post.html
    src="underConstruction_a2c.png"
    caption="Page-Flip example" %}

# Direct Rendering Manager (DRM)

The DRM subsystem is huge, complex, and incredibly beautiful! For this reason,
in this post, we only going to make a micro scratch on this subsystem by
providing a 10000-foot view of its architecture and components.

DRM acts as an orchestrator/manager that enables multiple application requests
to use the graphics hardware without crashes; in other words, DRM orchestrates
access to the hardware resource. This is possible because the DRM has exclusive
access to the GPU and it is also responsible for managing all the requests by
putting them in a command queue. However, DRM also handles other resources such
as memory and synchronization.

As a general rule, a device driver should provide a mechanism and not a policy
{% include cite.html id="ldd" %}, and DRM also follows this rule. In this
sense, DRM provides an API via IOCTL operations that can be used by the
userspace for defining policy. Unfortunately, using these IOCTL operations in
the user space application is tedious and has a great chance to introduce
errors, for this reason, we have a low-level library named libdrm that
facilitates the interaction with the kernel space. Now that you have this big
picture of the DRM, let's see it with more details.

## DRM Architecture

In Figure 5 I tried to provide an overview of the graphic stack that closely
interacts with DRM, take a minute to see the picture, and pay extra attention
to the **libdrm**, **DRM Core**, and **DRM Driver** elements.

**Notice:**
In my humble opinion, have this clear separation of the architectural elements
in your mind can help during the documentation reading.
{: .warning-box}

 {% include image-post.html
   src="posts/graphics/drm_api.png"
   style="width: 50%"
   caption="DRM architecture, image based on [3]" %}

For simplicity sake, let's examine the picture elements in topics:

1. **libdrm**: This library is a simple IOCTL wrapper for all operations
   provided by DRM.
2. **DRM Core**: This part of the DRM architecture provides a basic framework
   for all drivers under DRM subsystem. This component is a top-level
   abstraction that defines the basic behavior of drivers under DRM umbrella.
3. **DRM Driver**: It is the specific part of the target GPU and the developer should implement the rest of the required IOCTL operations to make the driver work. It is also possible to extends the already implemented operations to provide an specific behaviour.

Some of the IOCTL operations can only be controlled by a single process for security and for concurrency reasons. For this reasons the DRM restricts the processes that have access to the file `/dev/dri/card{X}` to a single processes marked as master (flag `SER_MASTER`). An example of a processes that have the Master control it is the X server, which becames master at the moment it is start and yield this permition when it finish. The master processes, became responsible for providing authorization to the other processes (`DRM_AUTH`);

## Managing Graphics Buffer in the Kernel

In the beginning of the development of graphic modules the GPUs state load the context per processes, which is not efficient. Additionally the screen compositors requires an efficient mechanism to share buffers off-screen. To solve this problem, it was developed the **Graphics Execution Manager (GEM)** which is resposible to expose an API to the user space that enables the memory management. An program at the user space level can create, manipulate and destroy memory object that live at the GPU. This objects are called GEM objects and from the user space perpective they are persistent and because of this it is not necessary to reload the data when the process retrieve the control over the GPU.

Every time that the application needs memory, they asked to the GEM driver; In its turn, GEM is responsible to keep track of the used memory and control the allocation/deallocation. If the application closes the received descriptor or if it ends, the memory is deallocated.

Another feature provided by GEM it is the ability to share objects with different processes. This is achieved by using a feature named **Gem names**, which provides a global namespace; a GEM Name can only refers to a unique memory region allocated at the same device. GEM provides the flink operation to getting a GEM name from the GEM file, the processes may pass this name to other process via IPC. However, a processes that wants to share its GEM object with other process need to convert its GEM handler into a DMA-BUF (we will explain in below) file descriptor and then pass it to the other processes.

**DMA Buffer Sharing (DMA-BUF)**
It is an internal kernel API provided by the Kernel designed to provide mechanisms for sharing buffers via DMA with multiple devices.
{: .notice_warning}

## Kernel Mode-Setting (KMS)

All graphic card or video adapter requires an initial set up to configure the
mode (resolution, color depth, and refresh rate) that fits into the monitor
features. This operation is called **mode-setting** and usually requires
hardware permission to set up these properties (this information, most of the
time, are kept in the hardware register). In the DRM subsystem, we have the
Kernel Mode-Setting (KMS) which is responsible for handling the mode-setting
operations.

It is important to highlight that the mode needs to be adjusted before the
framebuffer begin used.
{: .info-box}

One of the main characteristic of DRM framework it is the support for **Atomic
operations** for KMS (you going to hear about this many times). This concept
relies upon the idea that we only update the hardware state if the user
requested state is valid (we have mechanisms for checking it per driver).
Notice that this concept avoids the situation wherein the hardware is put in an
inconsistent state and cause the wrong programming sequence in the target
hardware. The way that the userspace can program this state is by providing a
bunch of information via **properties** for changing **objects** for specific
system setup. Next, the DRM subsystem going to take the object and properties
and sent them to the target graphic driver (e.g., amdgpu, vkms, etc) for
validation and commit. What happens if the state is invalid? We drop it and
report for the userspace which gives the application a chance to submit another
state.

The KMS implementation resembles the pipeline used to build an image in the hardware, basically, this model is composed of the following elements:

1. **CRTC (CRT Controller)**: Represents a scanout engine that points to a scanout buffer (framebuffer). Basically, it has to read the pixel framebuffer and generate the video mode timing with the support of PLL. The number of CRTC is equivalent to the number of independent hardware outputs that the hardware can genarate at the same time. So, for having multiple displays it is required to have one CRTC per screen; another example it is the multiple display showing the same iamge.
2. **Connector**: represents where the display controller send the video signal from one scanout operation to the screen. Usually, each connectors corresponds to one phisical connector in the hardware witch in each output display is permanently fixed (HDMI, VGA, DVI...)
3. **Encoders**: The display controller requires an encoder per video mode timing that is suitable to the connectors. An encoder represents a hardware block capable of performing codification (e.g., TMDS, LVDS, DAC, etc).
4. **Plane**: It is a memory object containing the buffer used by the scanout engine (CRTC). The plane that accomodate the framebuffer receives the name of primary and it is mandatory that every CRTC have at least one plane associate with itself. Note that is possible to have other planes that can be composed on-the-fly.

{% include image-post.html
    src="posts/graphics/drm_internals.png"
    style="width: 50%"
    caption="DRM pipeline, image based on [1]" %}

## DRM Alphabet Soup and terms

When I read any code in the DRM or in the documentation, I constantly find a lot of acronyms that did not make any sense for me in that time. Follows a summary of the meaning of some of these acronyms:

**Acronyms:**
1. **BO**: Buffer Object
2. **CMA**: Contiguous Memory Allocator
3. **GTT**: Graphics Translation Table
4. **DPMS**: Display Power Management Allocator
5. **BPP**: Bits Per-Pixel
6. **EDID**: Extended Display Identification Data
7. **IGP**: Integrated Graphics Processor
8. **UMA**: Unified Memory Architecture
9. **Sink**: Display
10. **Stream**: 
11. **Scanout**: 
{: .notice_warning}

## Reference

1. [Kernel Mode Setting](https://dri.freedesktop.org/docs/drm/gpu/drm-kms.html)
2. [Direct Rendering Manager - Wikipedia](https://en.wikipedia.org/wiki/Direct_Rendering_Manager)
4. [Screen Tearing](https://en.wikipedia.org/wiki/Screen_tearing)
5. [Compositing](https://en.wikipedia.org/wiki/Compositing)
6. [libdrm](https://cgit.freedesktop.org/drm/libdrm)


{% include print_bib.html %}
