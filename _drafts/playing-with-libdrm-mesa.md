---
layout: post
title: "Compile, install, debug, and use custom Mesa"
date: 2020-07-18
published: true
categories: "others"
---

{% include add_ref.html id="mesawiki"
    title="Mesa"
    date="2020-05-08"
    url="https://en.wikipedia.org/wiki/Mesa_(computer_graphics)" %}

{% include add_ref.html id="mesasite"
    title="Mesa Official Website"
    date="2020-05-08"
    url="https://mesa3d.org/" %}

{% include add_ref.html id="mesadebug"
    title="Mesa Debugging Presentation"
    date="2018-06-04"
    url="https://www.slideshare.net/GlobalLogicUkraine/mesa-and-its-debugging" %}

{% include add_ref.html id="ballmerpeak"
    title="Debugging mesa and the linux 3D graphics stack"
    date="2019-06-11"
    url="http://ballmerpeak.web.elte.hu/devblog/debugging-mesa-and-the-linux-3d-graphics-stack.html" %}

{% include add_ref.html id="mesonbuild"
    title="The Meson Build system"
    date="2020-07-19"
    url="https://mesonbuild.com/" %}

{% include add_ref.html id="mesarequirementes"
    title="Mesa Requirements"
    date="2020-07-19"
    url="https://docs.mesa3d.org/install.html#requirements" %}

In this post, I want to describe how to compile and use Mesa3D, if you work in
any layer of Linux Graphic stack this sort of knowledge may be really handy.

# Command summary

**If you did not read this tutorial yet, skip this section. I added this
section as a summary for someone that already read this tutorial and just want
to remember a specific command.**
{: .info-box}

&rarr; Basic commands:

```bash
git clone https://gitlab.freedesktop.org/mesa/mesa
meson build --prefix /opt/mesa --libdir /opt/mesa/lib/x86_64-linux-gnu \
  --buildtype debugoptimized -Dc_args=-fno-omit-frame-pointer \
  -Dcpp_args=-fno-omit-frame-pointer -Dc_link_args=-fno-omit-frame-pointer \
  -Dcpp_link_args=-fno-omit-frame-pointer \
  -Dpkg_config_path=/usr/lib/x86_64-linux-gnu/pkgconfig -Dgallium-xa=false \
  -Dgallium-vdpau=true -Dgallium-va=true -Dgallium-omx=bellagio \
  -Dgallium-xvmc=false -Dplatforms=x11,drm,surfaceless \
  -Dgallium-drivers=radeonsi,swrast -Ddri-drivers= -Dvulkan-drivers=amd
ninja -C build
```

# First of all, what is Mesa3D?

Graphic Stack on Linux-based systems is composed of many different components
that range from low-level (e.g., kernel driver) to a high-level operation
(e.g., game engine). Mesa is one of the key elements in the graphic stack since
it plays a translation layer role between graphics APIs (e.g., OpenGL and
Vulkan) and the operations sent to the kernel. It is important to highlight
that Mesa implements vendor-specific code for taking advantage of device
peculiarities{% include cite.html id="mesawiki" %}{% include cite.html id="mesasite" %}.

# Mesa compilation

First of all, let's clone the repository by using:

```
git clone https://gitlab.freedesktop.org/mesa/mesa
```

We going to need `meson`{% include cite.html id="mesonbuild" %} for building
Mesa, usually, you can find it available in your Distribution; for example, for
installing it on Debian or ArchLinux you can use:

```
sudo apt install meson # Debian
sudo pacman -Ss meson # ArchLinux
```

Mesa has a bunch of external dependencies that you need to figure out by
yourself since it depends on what do you need. From the documentation, Mesa
suggested{% include cite.html id="mesarequirementes" %}:

> *Here are some common ways to retrieve most/all of the dependencies based on the packaging tool used by your distro.*
> ```
> zypper source-install --build-deps-only Mesa # openSUSE/SLED/SLES
> yum-builddep mesa # yum Fedora, OpenSuse(?)
> dnf builddep mesa # dnf Fedora
> apt-get build-dep mesa # Debian and derivatives
> ... # others
> ```

Again, it varies for each person, in my case I had to install:

```
libxxf86vm-dev libxshmfence-dev libxxf86vm-dev libxcb-present-dev
libxcb-dri3-dev libxcb-dri2-0-dev libx11-xcb-dev libxcb-glx0-dev libxdamage-dev
xdamage-dev libva-dev libomxil-bellagio-dev libvdpau-dev
```

Alternatively, you can ignore all dependencies for a while and install them
one-by-one during the build preparation step. Speaking of build preparation, in
this tutorial, we want to install Mesa in a specific path to make it isolated
from the version distributed by your distro version and we also want to provide
some other options.

For changing the default path used by Mesa you going to need two parameters:

1. `--prefix`: This flag allows us to change the default installation prefix
   used by mesa, for this tutorial we use `/opt/mesa`.
2. `--libdir`: In this flag, we going to point out the library directory, which
   in my case is: `/opt/mesa/lib/x86_64-linux-gnu`.

All the above options are based on my personal choices, feel free to change
anything as you want. Now, keep in mind that you can pass different compilation
options to meson in order to generate a customizable build. In my case, I have
an AMD based system and for this reason, I'm going to add a specific option for
it; again, you can change some of these parameters bases on your need. In the
Mesa directory, try:

```
meson build --prefix /opt/mesa --libdir /opt/mesa/lib/x86_64-linux-gnu \
  --buildtype debugoptimized -Dc_args=-fno-omit-frame-pointer \
  -Dcpp_args=-fno-omit-frame-pointer -Dc_link_args=-fno-omit-frame-pointer \
  -Dcpp_link_args=-fno-omit-frame-pointer \
  -Dpkg_config_path=/usr/lib/x86_64-linux-gnu/pkgconfig -Dgallium-xa=false \
  -Dgallium-vdpau=true -Dgallium-va=true -Dgallium-omx=bellagio \
  -Dgallium-xvmc=false -Dplatforms=x11,drm,surfaceless \
  -Dgallium-drivers=radeonsi,swrast -Ddri-drivers= -Dvulkan-drivers=amd
```

This step may fail due to lack of dependency, see the message, and figure out
the correct package in your system.
{: .warning-box}

If the above command ends its execution without any issue, it means that you
are ready for compiling:

```
ninja -C build
```

# Mesa installation

From the previous section, we used the `/opt/mesa/` as a place to keep our
custom version of Mesa. Now we need to setup our system for use it. First of
all, let's install our Mesa version:

```
sudo ninja -C build install
```

After the installation you should see Mesa files at `/opt/mesa/`:

```
ls /opt/mesa/
include  lib  share
```

Now, we need to instruct our system to use `/opt/mesa` library by adding the
following line inside `/etc/environment`:

```
LIBGL_DRIVERS_PATH=/opt/mesa/lib/x86_64-linux-gnu/dri
```

Next we need to create a `mesa.conf` file inside `/etc/ld.so.conf.d/` and add
the following content on it:

```
/opt/mesa/lib/x86_64-linux-gnu
```

We are almost done here, but before we start to use our Mesa version let's
first prepare for a sanity check of our installation. First of all, see the
latest commit message in your Mesa repo, for example, in my case I have:

```
2b343238a1f zink: free all ntv allocations after creating shader module
```

Keep in mind the latest git commit in your Mesa repository. Next, run the
command below and again keep in mind the out put:

```
glxinfo | grep Mesa
TODO
```

Ok, with the above information let's finally start to use our custom version of
Mesa:

```
sudo systemctl restart gdm
```

If nothing apparently went wrong, we just need to make sure that we are using
our Mesa version. Just type:

```
glxinfo | grep Mesa
OpenGL core profile version string: 4.6 (Core Profile) Mesa 20.2.0-devel (git-2b343238a1)
OpenGL version string: 4.6 (Compatibility Profile) Mesa 20.2.0-devel (git-2b343238a1)
OpenGL ES profile version string: OpenGL ES 3.2 Mesa 20.2.0-devel (git-2b343238a1)
```

As you can see from the above output, my Mesa version indicates the git hash
from my Mesa branch. Voilà, my friend, you're now using your custom mesa
version.

# Playing with Mesa

How about playing a little bit with Mesa by adding a couple of prints in the
code? I think this is the easy way, right?

In this sense, open the file `src/gallium/drivers/radeonsi/si_texture.c` and
add the following print in below function:

```
static void si_set_tex_bo_metadata(struct si_screen *sscreen, struct si_texture *tex)
{
   struct pipe_resource *res = &tex->buffer.b.b;
    ...
printf("===> Hello bo metadata\n");
    ...
}
```

Compile, install, and reboot gdm again:

```
sudo ninja -C build install
sudo systemctl restart gdm
```

Open a terminal, and run the classical `glxgears` and pay attention in the
output:

```
glxgears
===> Hello bo metadata
```

## Conclusion

At this moment, I suppose that you already have a basic knowledge of how to
build and see changes in the Mesa code. I recommend you to go ahead and learn
more about debugging techniques on Mesa, see the reference in this page for
further information.

{% include print_bib.html %}
