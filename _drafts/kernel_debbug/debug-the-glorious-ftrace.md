---
layout: post
title: "The glorious Ftrace"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

{% include add_ref.html id="lwnftrace1"
    title="Debugging the kernel using Ftrace - part 1"
    author=" Jonathan Corbet and Steven Rostedt"
    date="2009-12-09"
    url="https://lwn.net/Articles/365835/" %}

{% include add_ref.html id="lwnftrace2"
    title="Debugging the kernel using Ftrace - part 2"
    author=" Jonathan Corbet and Steven Rostedt"
    date="2009-12-22"
    url="https://lwn.net/Articles/366796/" %}

{% include add_ref.html id="ftrace"
    title="ftrace - Function Tracer"
    date="2020-03-30"
    url="https://siqueira.tech/doc/drm/trace/ftrace.html" %}

{% include add_ref.html id="ftrace"
    title="Secrets of the Ftrace function tracer"
    date="2010-01-20"
    url="https://lwn.net/Articles/370423/" %}

{% include add_ref.html id="vkmsdebug"
    title="On Writing VKMS driver with Debug Tools"
    date="2018-06-29"
    url="http://haneensa.github.io/2018/07/29/drmdebug/" %}

{% include add_ref.html id="vkmsdebug"
    title="ftrace: trace your kernel functions!"
    date="2018-06-29"
    url="https://jvns.ca/blog/2017/03/19/getting-started-with-ftrace/" %}

TODO

## Command Summary

If you did not read this tutorial yet, skip this section. I added this section
as a summary for someone that already read this tutorial and just want to
remember a specific command.
{: .info}

```
cd /sys/kernel/debug/tracing
echo 0 > tracing_on
echo function_graph > current_tracer
echo drm* > set_ftrace_filter
nm PATH/TO/OBJECT/FILE | grep " t "
nm PATH/TO/OBJECT/FILE | grep " T "
```

# Introduction

TODO

# Ftrace overview

The Ftrace option can be found under the `/sys` directory. For simplicity sake,
all of this page sections supposes that you are working inside the following
directory:

```
$ cd /sys/kernel/debug/tracing
```

Ftrace provides different trace mechanisms, you can see all the available
options by inspecting the `available_tracers` file:

```
$ cat available_tracers
hwlat blk mmiotrace function_graph wakeup_dl wakeup_rt wakeup function nop
```

The `nop` tracer means that we are not tracing anything which means that we are
running our system at full speed, usually, this is the default option in your
system. If you want to double-check which trace your system is using, you can
try:

```
$ cat current_tracer
nop
```

One of the most important thing when you are tracing something, it is a
readable file wherein you can check all results. This file in the Ftrace is
called `trace`, and you can have a taste of it by using the command:

```
$ cat trace | head -n 20

# tracer: nop
#
# entries-in-buffer/entries-written: 0/0   #P:8
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
```

As can be seen from the above output, Ftrace provides a readable output for
further inspection. It is interesting to highlight that every time that you
read from this file, you temporarily disable the tracing; as soon as the read
operation finishes the tracing is enabled again.

# The `function_graph` trace

The previous section was an introduction to make you a little bit more
comfortable with Ftrace files, now we want to do something a little bit more
entertaining for this reason we going to play with `function_graph` option.
Let's enable this tracer:

```
$ echo function_graph > current_tracer
$ cat current_tracer
function_graph
```

As the above command illustrates, we enabled the `function_graph` trace in our
system and not it is time to take a look at its output:

```
cat trace | head -n 20
# tracer: function_graph
#
# CPU  DURATION       FUNCTION CALLS
# |     |   |          |   |   |   |
  2)               |             ttwu_do_activate() {
  2)               |               activate_task() {
  2)               |                 enqueue_task_fair() {
  2)               |                   enqueue_entity() {
  2)   0.330 us    |                     update_curr();
  2)   0.311 us    |                     __update_load_avg_se();
  2)   0.311 us    |                     __update_load_avg_cfs_rq();
  2)   0.281 us    |                     update_cfs_group();
  2)   0.291 us    |                     account_entity_enqueue();
  2)   0.350 us    |                     __enqueue_entity();
  2)   3.978 us    |                   }
  2)   0.271 us    |                   hrtick_update();
  2)   5.129 us    |                 }
  2)   5.831 us    |               }
  2)               |               ttwu_do_wakeup() {
  2)               |                 check_preempt_curr() {
```

Before we keep digging into the Ftrace option, it is worth to understand a
little bit better its output {% include cite.html id="ftrace" %}:

* All values in the Ftrace are in microseconds;
* The output gives the function name followed by `{` or `;`. All functions
  between `{` and `}`, are part of the stack of the main function and when we
  see functions with `;` means that we are in a leaf function;
* At the end of each `{` we have the total time elapsed for executing the
  function;
* Some times, you can see a symbol in front of each time. Each of these
  elements represents a piece of delay information, follows the description of
  each one:
- `$`: delay greater than 1 second;
- `@`: delay greater than 100 millisecond;
- `*`: delay greater than 10 millisecond;
- `#`: delay greater than 1000 microsecond;
- `!`: delay greater than 100 microsecond;
- `+`: delay greater than 10 microsecond;
- ` `: delay less than or equal to 10 microsecond.

I recommend you to take 5 or 10 minutes looking at this file, just for trying
to get used to it.

# Ftrace filters

If you inspected the `trace` file you probably going to notice a bunch of system functions that makes this file really hard to read. Ftrace provide a filter option that allow us to specify a set of functions that we want to follow, for illustrating this feature I'm going to use `amdgpu` driver, however, you can use any driver that you want by change a little bit the steps provided here.

First of all, let's disable the `ftrace` by set zero to `tracing_on` file:

```
$ cd /sys/kernel/debug/tracing
$ echo 0 > tracing_on
```

Also, let's clean the `trace` file:

```
echo > trace
```

Now, let's enable `function_graph`:

```
$ echo function_graph > current_tracer
```

Ok, we are ready for see how to set filter options. First of all, take a look at `set_ftrace_filter`:

```
$ cat set_ftrace_filter
#### all functions enabled ####
```

As you can see, we are capturing all the available functions in the Kernel and now we want to limit its range. We have a couple of options here:

1. You can specify the function name directly; For example:

```
echo drm* > set_ftrace_filter
```

2. You can specify an especific function, for example:

```
echo drm_connector_init > set_ftrace_filter
```

Keep in mind that `set_ftrace_filter` is a simple file, which means that `>` going to overwrite the current content and `>>` going to append the new content to the end of the file. You probably want to use something like this:

```
echo amdgpu_dm_* > set_ftrace_filter # Only display manager functions for AMD driver
echo dm_restore_drm_connector_state >> set_ftrace_filter
```

After you set the filter take a few minutes to contemplate the file `set_ftrace_filter` and you will notice that many functions that match the pattern that you specified are displayed in that file. We are almost done here, but before we enable ftrace again I want to share a tip for find some specific function. Sometimes we have difficult to find the functions that need to be added to the filter, I like to use `nm` tool in a specific object file for capturing an small set of function that can be useful for my debugging; for example, the command below going to give me the exported function (`T` label in nm) from `amdgpu_dm`.

```
nm drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.o | grep " T "
```

We can also take the static function by use (`t` label in nm):

```
nm drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.o | grep " t "
```

Let's finally enable the log by using:

```
echo 1 > tracing_on
```

You can catch the output by reading the `trace_pipe` file and save the output in another file with the below command:

```
cat trace_pipe | tee ~/trace.log # wait for sys calls with drm and vkms prefix
```

## The super `trace_printk()`

I have to admit that `pr_info()` is my favorite debug tool, and I always start to dig into different issues by using it. However, this option is not ideal most of the time, specially when we play with GPU bugs; in those case, don't panic! We have the glorious `trace_printk()` to rescue us! In a few word, this is a print option going to be displayed inside the `trace` file. For example, let's add a simple message in `do_one_initcall` function:

```
TODO
```

Now, compile, install, and reboot the new kernel. Set the following filter:

```
echo do_one_initcall* > set_ftrace_filter
```

After you enable and capture the log, you should see something like this:

```
TODO
```

{% include print_bib.html %}
