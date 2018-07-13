---
layout: post
title:  "Establishing the necessary knowledge and jargon"
date:   2018-07-13
categories: drm
published: false
---

When I started to dive into the DRM subsystem, I had a no background on the graphic stack. As a result, during my collaboration to develop the Virtual Kernel Mode-Setting (VKMS) I constantly read the documentation. Seriously, I read the documentation an enormous amount of time and I really recommend any newcomer to do the same because the DRM documentation is great. However, most of the time when I started to read the documentation I found a lot of difficult to understand, but the reason was simple: I did not have the required knowledge and I did not understand the jargon. Inspired by that, I decided to write a post with the goal to provide an overview about the DRM subsystem to try to make easy for newcomers to take more advantage from the documentation and also better understand the code.

Please, keep in mind two things:

1. Most of the content here is derived from another source, and I did my best to refer all of them;
2. If you find any misconception or error, please let me know, I will be glad to improve this content.

## Basic Concepts

Before we take a careful look at the DRM subsystem, it is important to acquire some general knowledge that will help to better understand the documentation and the subsystem itself. There is a lot of information to look into, however, I just highlight here the most important one to start.

### Multiple Graphic Devices Management

During your journey into the DRM documentation, you will see references to "Integrated Graphics" and "Dedicated Graphics Cards". Follows the explanations for each one:

* **Integrated Graphics (or Shared Graphic Solution/Integrated Graphics Processor/Unified Memory Architecture)**: Usually, this sort of processor has less processing unit and the memory is shared with the CPU. We can also fit the on-board graphics into the category. You can find this graphics into the Intel, AMD, and ARM processors for example.
* **Dedicated Graphics Card (or Discrete Graphics)**: It has many processing units and a dedicated memory. AMR Radeon and Nvidia are examples of this sort of devices.

These two concepts together, drive us to the idea of **GPU Switching** which is responsible to control the use of the multiple GPUs. Switching between GPUS is really convenient for save energy, specially in mobile and laptop devices.

### Framebuffer and Display Mode

**Framebuffer** is a portion of memory responsible to store the bitmap to be displayed; in other words, the image to be displayed in the screen is stored at the framebuffer and the bit pattern is read and displayed on the screen according to the refresh rate. Note the modern devices have dedicated hardware for handling the framebuffer and convert them directly to video signal. Figure 1 illustrates this concept:

{% include image-post.html
  path="underConstruction_a2c.png"
  caption="Fig 1: a view of framebuffer, image based on [3]" %}

#### Display mode

Normally, device has operation **mode** that specifies how the framebuffer should act. A **mode** is defined by the combination of three elements:

1. **Screen Resolution (or display mode)**: It is the number of pixel that **can be showed** in each dimesion; usually, it is provided by "width X height" in pixel units. The resolution refers to the pixel density, which is the number of pixel per unit of distance or area.
2. **Color Depth (or bit depth)**: The number of bits used to represent the color of a single pixel in a bitmap or framebuffer. The best way to understand this property, it is look at the Figure 2.
  {% include image-post.html
    path="posts/color_deph_comp-min.png"
    caption="Fig 2: Color depth of 256, 128, 16, 4, and 2 bits (right to left)" %}
3. **Refresh Rate**: It is number of times per second which in the screen buffer of the monitor is updated. See the Video 1 below to get the notion how different refresh rate affects the image displayed by the monitor. Note that high refresh rate, means that the time to update the monitor buffer is shorter; for example, a refresh rate of 60Hz update the buffer around ~0.01666 per second, and 120Hz updates the buffer around ~0.00833 per second. Take care to not mix the concept of Frame Per Second (FPS) and Refresh Rate, former refers to the amount of frames the device can produce, and the latter it is how many times the buffers are updated.
  {% include youtube-player.html
    id="Q1cmhZs1P54?start=3"
    caption="Video 1: Slow motion Monitor refresh rates" %}

### Vertical Blanking Interval and Vertical Blank Interrupt

At my first interactions with the DRM documentation, I thought that Vertical Blanking Interval and Vertical Blank Interrupt are the same thing; however, there is a subtle difference between them:

* **Vertical Blanking Interval**: It is the time between the last frame line and the beginning of the first line of the next frame.
* **Vertical Blank Interrupt**: It is a feature find in some hardware, but not restricted to it, that generates signals when the display image has completely displayed and the screen could return to the start of the display.
{: .notice_warning}

Vblank work as a synchronization mechanism to inform via signal when a new image can be used. It is nice if the graphic device that generate the images is synchronized with display refresh rate, it they not match it can generate a problem named "Screen tearging". See Video 2 to see an example of the screen tearing problem. Finally, keep in mind that during the vblank interval it is really convenient to perform video operations.

  {% include youtube-player.html
    id="jVAFuUAKPMc"
    caption="Video 2: Example of tearing in a game" %}

### Page-Flipping (Double Buffer)

Before explain the concept of Page-Flipping, take a look at the Figure 3. In this picture you can see the representation of two different sides, one that represents the graphics been generated and the other representing the screen. At the first part of the image the screen display the buffer content, while the graphics produces a new content in the second buffer; both buffers are able to be displayed in the screen. When the monitor send the signal that the first image was completely displayed at the screen, the graphic card change the image pointer for the new image and then the screen start to render the new image. Afterward, the graphic card start to produce the new image and this process keep going.

  {% include image-post.html
    path="underConstruction_a2c.png"
    caption="Fig 3: Page-Flip example" %}

This example show how page-flip works. It is important to highlight that both buffers are able to be displayed, but at some point on buffer is enabled and the other not.

### Compositing Window Manager

This subject represents an huge area, and here I just want to provide a top view of the subject to support someone that will read the DRM documentation. In this sense, we start with a brief explanation of Compositing:

**Compositing**
It is the combination of multiple image into a single one with the goal to offer the illusion that all elements are the same in the scene. All the compositing requires the replacement of one part of the image by another and some software manage this replacement.
{: .notice_warning}

A **compositing window manager** provide buffers for the applications to drawn their own window. The window manager take all the application buffer together in a single buffer to produce the final image to be written in the screen. Note that the manager can make the operation of scaling, duplicating, rotating, blurring, 3D effects, and others. Figure 4, provide an overview of the Compositing window work.

  {% include image-post.html
    path="underConstruction_a2c.png"
    caption="Fig 3: Page-Flip example" %}

## Direct Rendering Manager (DRM)

## DRM Alphabet Soup

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
{: .notice_warning}

## Reference

1. [Kernel Mode Setting](https://dri.freedesktop.org/docs/drm/gpu/drm-kms.html)
2. [Direct Rendering Manager - Wikipedia](https://en.wikipedia.org/wiki/Direct_Rendering_Manager)
3. Computer Organization and Design MIPS Edition: The Hardware/Software Interface - DA Patterson, JL Hennessy
4. [Screen Tearing](https://en.wikipedia.org/wiki/Screen_tearing)
5. [Compositing](https://en.wikipedia.org/wiki/Compositing)
