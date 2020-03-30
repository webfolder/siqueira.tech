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


The Ftrace option can be find under the `/sys` directory. For simplicity sake, all of this page sections supposes that you are working inside the following directory:

```
cd /sys/kernel/debug/tracing
```

Ftrace provide different trace mechanism, you can see all the available option by inspect the `available_tracers` file:

```
cat available_tracers
hwlat blk mmiotrace function_graph wakeup_dl wakeup_rt wakeup function nop
```

The `nop` tracer means that we are not tracing anything and we are running our system at 100% speed, usually, this is the default option in your system. If you want to double-checking which trace your system is using, you can try:

```
cat current_tracer
nop
```

One of the most important thing when you are tracing something, it is a readable file wherein you can check results. This file in the Ftrace is called `trace`, and you can have a taste of it with the following command:

```
cat trace | head -n 20

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

As can be seen from the above output, Ftrace provide a readable output for further inspection. It is interesting to highlight that every time that you read from this file, you temporarily disable the tracing; as soon as the read operation close the file descriptor the tracing is enabled again.

## The `function_graph` trace

The previous section was an introduction to make you a little bit more comfortable with Ftrace files, now we want to do something a little bit more entertaining for this reason we going to play with `function_graph` option. Let's start by enable this tracer:

```
echo function_graph > current_tracer
cat current_tracer
function_graph
```

As the above command illustrates, we enabled the `function_graph` trace in our system, if you take a look on it you should see something like this:

```
cat trace | head -n 20
# tracer: function_graph
#
# CPU  DURATION                  FUNCTION CALLS
# |     |   |                     |   |   |   |
  2)               |                        ttwu_do_activate() {
  2)               |                          activate_task() {
  2)               |                            enqueue_task_fair() {
  2)               |                              enqueue_entity() {
  2)   0.330 us    |                                update_curr();
  2)   0.311 us    |                                __update_load_avg_se();
  2)   0.311 us    |                                __update_load_avg_cfs_rq();
  2)   0.281 us    |                                update_cfs_group();
  2)   0.291 us    |                                account_entity_enqueue();
  2)   0.350 us    |                                __enqueue_entity();
  2)   3.978 us    |                              }
  2)   0.271 us    |                              hrtick_update();
  2)   5.129 us    |                            }
  2)   5.831 us    |                          }
  2)               |                          ttwu_do_wakeup() {
  2)               |                            check_preempt_curr() {
```

Before we keep dig into Ftrace, it is worth to understand a little bit better the above output {% include cite.html id="ftrace" %}:

* All values in the Ftrace are in microseconds;
* The output gives the function name followed by `{` or `;`. All functions between `{` and `}`, are part of the stack of the main function and when we see functions with `;` means that we are in a leaf function;
* At the end of each `{` we have the total time elapsed for execute the function; 
* Some times, you can see a symbol in front of each time. Each of this elements represents a delay information, follows the description of each one:
- `$`: delay greater than 1 second;
- `@`: delay greater than 100 millisecond;
- `*`: delay greater than 10 millisecond;
- `#`: delay greater than 1000 microsecond;
- `!`: delay greater than 100 microsecond;
- `+`: delay greater than 10 microsecond;
- ` `: delay less than or equal to 10 microsecond.
*

## The super `trace_printk()`

I have to admit that `pr_info()` is my favorite debug tool, and I always start to dig into different issues by using it. However, this option does not better suite every time specially when we play with GPU bugs; in those case, no panic! We have the glorious `trace_printk()` to rescue us! This printk 


## Ftrace filters

Sometimes we have problems to find the functions that need to be added to the filter, an easy way to handle it is by using the command:

```
nm drivers/gpu/drm/amd/display/amdgpu_dm/amdgpu_dm.o | grep " T "
```
