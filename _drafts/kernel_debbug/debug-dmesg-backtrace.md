---
layout: post
title: "Dmesg and backtrace"
date: 2019-11-24
published: true
categories: "linux-kernel-basic"
---

{% include add_ref.html id="intelBactrace"
    title="How to get kernel backtrace"
    author="Rodrigo Siqueira"
    date="2016-06-21"
    url="https://01.org/linuxgraphics/documentation/bugs-and-debugging/how-get-kernel-backtrace" %}

{% include add_ref.html id="x86wiki"
    title="Wikipedia x86"
    url="https://en.wikipedia.org/wiki/X86" %}

{% include add_ref.html id="kernelStack"
    title="Kernel Stacks"
    url="https://siqueira.tech/doc/drm/x86/kernel-stacks.html" %}

##

## Dissecting Backtrace

When we investigate an issue in the Kernel there is a good chance that you see a Kernel backtrace, understand it is a valuable knowledge for helping you to find the root cause of the problem. For this reason we need to dissect this log, let's start with a real dmesg log:

```
[  181.695806] serial 00:04: activated
[  181.695810] [drm] PSP is resuming...
[  181.704090] sd 9:0:0:0: [sda] Starting disk
[  181.715663] [drm] reserve 0x400000 from 0xf47f800000 for PSP TMR
[  181.725270] [drm] psp command (0x5) failed and response status is (0xFFFF0007)
[  181.858942] [drm] kiq ring mec 2 pipe 1 q 0
[  181.859204] amdgpu: [powerplay] dpm has been enabled
[  182.007749] ata2: SATA link down (SStatus 0 SControl 330)
[  182.008981] ata6: SATA link down (SStatus 0 SControl 330)
[  182.009001] ata5: SATA link down (SStatus 0 SControl 330)
[  182.009020] ata1: SATA link down (SStatus 0 SControl 330)
[  182.109924] [drm] pstate TEST_DEBUG_DATA: 0x3FFC0000
[  182.109934] ------------[ cut here ]------------
[  182.110000] WARNING: CPU: 4 PID: 289 at drivers/gpu/drm/amd/amdgpu/../display/dc/dcn10/dcn10_hw_sequencer.c:1020 dcn10_verify_allow_pstate_change_high+0x37/0x290 [amdgpu]
[  182.110000] Modules linked in: amdgpu nls_iso8859_1 kvm_amd ccp kvm amd_iommu_v2 gpu_sched eeepc_wmi asus_wmi ttm sparse_keymap wmi_bmof mxm_wmi irqbypass snd_hda_codec_realtek drm_kms_helper snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_intel_dspcfg joydev snd_hda_codec syscopyarea sysfillrect sysimgblt fb_sys_fops snd_hwdep drm snd_hda_core crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_pcm snd_seq aesni_intel input_leds glue_helper crypto_simd cryptd snd_timer snd_seq_device snd k10temp soundcore mac_hid video wmi sch_fq_codel parport_pc ppdev lp parport ip_tables x_tables hid_generic usbhid hid igb ahci i2c_piix4 i2c_algo_bit libahci dca gpio_amdpt gpio_generic
[  182.110020] CPU: 4 PID: 289 Comm: kworker/u64:6 Not tainted 5.5.0-rc7-SUSPEND-BUG-NEXT+ #4
[  182.110020] Hardware name: System manufacturer System Product Name/ROG STRIX B450-F GAMING, BIOS 2008 03/04/2019
[  182.110023] Workqueue: events_unbound async_run_entry_fn
[  182.110074] RIP: 0010:dcn10_verify_allow_pstate_change_high+0x37/0x290 [amdgpu]
[  182.110076] Code: 8b 87 30 03 00 00 48 89 fb 48 8b b8 b0 01 00 00 e8 ce 44 01 00 84 c0 0f 85 50 02 00 00 80 3d df 64 1f 00 00 0f 85 48 02 00 00 <0f> 0b 80 bb b8 01 00 00 00 0f 84 34 02 00 00 48 8b 83 30 03 00 00
[  182.110076] RSP: 0018:ffffa44080677738 EFLAGS: 00010246
[  182.110077] RAX: 0000000000000000 RBX: ffff8c1e887b0000 RCX: 0000000000000000
[  182.110078] RDX: 0000000000000000 RSI: ffff8c1e90919748 RDI: ffff8c1e90919748
[  182.110078] RBP: ffffa44080677748 R08: 0000002a6698ebbe R09: ffffffffa932d404
[  182.110079] R10: 000000000000046d R11: 00000000001e9968 R12: ffff8c1e887b0000
[  182.110079] R13: ffff8c1e8abf9000 R14: ffff8c1e8ce06e40 R15: ffff8c1e6c141da8
[  182.110080] FS:  0000000000000000(0000) GS:ffff8c1e90900000(0000) knlGS:0000000000000000
[  182.110080] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  182.110081] CR2: 0000000000000000 CR3: 00000003ef464000 CR4: 00000000003406e0
[  182.110081] Call Trace:
[  182.110134]  dcn10_optimize_bandwidth+0x40/0x140 [amdgpu]
[  182.110182]  dc_commit_state+0x7d9/0x950 [amdgpu]
[  182.110233]  amdgpu_dm_atomic_commit_tail+0xcf5/0x1fe0 [amdgpu]
[  182.110266]  ? amdgpu_bo_move+0x17f/0x2c0 [amdgpu]
[  182.110269]  ? ttm_bo_handle_move_mem+0x148/0x5b0 [ttm]
[  182.110271]  ? ttm_bo_validate+0x142/0x160 [ttm]
[  182.110304]  ? amdgpu_bo_pin_restricted+0x276/0x2b0 [amdgpu]
[  182.110307]  ? ttm_bo_move_to_lru_tail+0x2d/0xc0 [ttm]
[  182.110309]  ? ww_mutex_unlock+0x26/0x30
[  182.110358]  ? fill_dc_plane_info_and_addr+0x360/0x360 [amdgpu]
[  182.110407]  ? dm_plane_helper_prepare_fb+0x211/0x290 [amdgpu]
[  182.110414]  commit_tail+0x99/0x130 [drm_kms_helper]
[  182.110418]  drm_atomic_helper_commit+0x123/0x150 [drm_kms_helper]
[  182.110467]  amdgpu_dm_atomic_commit+0x95/0xa0 [amdgpu]
[  182.110477]  drm_atomic_commit+0x4a/0x50 [drm]
[  182.110481]  drm_atomic_helper_commit_duplicated_state+0xcd/0xe0 [drm_kms_helper]
[  182.110485]  drm_atomic_helper_resume+0x60/0xd0 [drm_kms_helper]
[  182.110534]  dm_resume+0x2ac/0x390 [amdgpu]
[  182.110565]  amdgpu_device_ip_resume_phase2+0x6b/0xd0 [amdgpu]
[  182.110596]  ? amdgpu_device_fw_loading+0xae/0x130 [amdgpu]
[  182.110628]  amdgpu_device_resume+0xa5/0x340 [amdgpu]
[  182.110630]  ? enqueue_entity+0x146/0x670
[  182.110631]  ? __switch_to_asm+0x34/0x70
[  182.110662]  amdgpu_pmops_resume+0x58/0x60 [amdgpu]
[  182.110664]  pci_pm_resume+0x5c/0x90
[  182.110665]  ? pci_pm_thaw+0x80/0x80
[  182.110667]  dpm_run_callback+0x56/0x150
[  182.110668]  device_resume+0x118/0x220
[  182.110669]  async_resume+0x1e/0x60
[  182.110670]  async_run_entry_fn+0x3c/0x150
[  182.110671]  process_one_work+0x1d1/0x3e0
[  182.110672]  worker_thread+0x4d/0x400
[  182.110674]  kthread+0x104/0x140
[  182.110675]  ? process_one_work+0x3e0/0x3e0
[  182.110675]  ? kthread_park+0x90/0x90
[  182.110676]  ret_from_fork+0x22/0x40
[  182.110678] ---[ end trace 999b4c89fc5478f3 ]---

```

We going to dissect this backtrace top-down.

### General ideas

Before we start to take a look at each detail it is important to equip you with some basic information which includes: backtrace organization, type, and registers. First of all, the kernel backtrace is usually comprised between these two marks:

1. Begining: `------------[ cut here ]------------`
2. Ending: `---[ end trace HASH ]---`

All the required data can be seen between these two string; notice that your log may have multiple of this backtraces blocks.

If you keep looking at the backtrace log you will see a set of registers such as `RIP`, `RSP`, `RAX`, `RDX`, etc. The character `R` is a suffix that means the target machine uses 64 bits architecture, and it can also use `E` if we are in a 32 bit architecture {% include cite.html id="x86wiki" %}, and the other characters after this suffix are related to the achitecture `x86`. The most important register it is the `IP` (Instruction Pointer) register, since it indicates where the problems occorred. See below and example:

```
...
RIP: 0010:dcn10_verify_allow_pstate_change_high+0x37/0x290 [amdgpu]
...
RSP: 0018:ffffa44080677738 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8c1e887b0000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8c1e90919748 RDI: ffff8c1e90919748
RBP: ffffa44080677748 R08: 0000002a6698ebbe R09: ffffffffa932d404
R10: 000000000000046d R11: 00000000001e9968 R12: ffff8c1e887b0000
R13: ffff8c1e8abf9000 R14: ffff8c1e8ce06e40 R15: ffff8c1e6c141da8
FS:  0000000000000000(0000) GS:ffff8c1e90900000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
...
```

### Type of backtrace problem

We have different types of backlog, usually, you can identify it in the first part of the log below `[cut here]` string. The most common set of errors are:

1. `WARNING`: Usually warnings follow the below patter:

```
WARNING: CPU: [NUM] PID: [NUM] at [FILE_PATH]:[LINE] [FUNCTION_NAME]+[HEX_OFFSET] [DRIVER]
```
The most important information in a warning message it is the `FILE_PATH` and `FUNCTION_NAME` which indicates the exactly place that the issue started {% include cite.html id="playModules" %}. See below a real example of this:

```
WARNING: CPU: 4 PID: 289 at drivers/gpu/drm/amd/amdgpu/../display/dc/dcn10/dcn10_hw_sequencer.c:1020 dcn10_verify_allow_pstate_change_high+0x37/0x290 [amdgpu]
```

2. `BUG`: 

BUGs will stop the current thread, so usually there's not a following call trace. In any case, all subsequent call traces are most likely issues that occur right after the main bug and those traces can be safely ignored.

## Call trace

In the backtrace added at the beginning of this post, you can see:

```
...
Call Trace:
 dcn10_optimize_bandwidth+0x40/0x140 [amdgpu]
 dc_commit_state+0x7d9/0x950 [amdgpu]
 amdgpu_dm_atomic_commit_tail+0xcf5/0x1fe0 [amdgpu]
 ? amdgpu_bo_move+0x17f/0x2c0 [amdgpu]
 ? ttm_bo_handle_move_mem+0x148/0x5b0 [ttm]
 ? ttm_bo_validate+0x142/0x160 [ttm]
 ? amdgpu_bo_pin_restricted+0x276/0x2b0 [amdgpu]
 ? ttm_bo_move_to_lru_tail+0x2d/0xc0 [ttm]
 ? ww_mutex_unlock+0x26/0x30
 ? fill_dc_plane_info_and_addr+0x360/0x360 [amdgpu]
 ? dm_plane_helper_prepare_fb+0x211/0x290 [amdgpu]
 commit_tail+0x99/0x130 [drm_kms_helper]
 drm_atomic_helper_commit+0x123/0x150 [drm_kms_helper]
 amdgpu_dm_atomic_commit+0x95/0xa0 [amdgpu]
...
```

EXPLICAR O GERAL...

I have to admit that I was bugged by the character `?` at the beginning of some functions, and after dig into the kernel documentation I ...

SOBRE O '?'

If the address does not fit into our expected frame pointer chain we still print it, but we print a ‘?’. It can mean two things:

either the address is not part of the call chain: it’s just stale values on the kernel stack, from earlier function calls. This is the common case.

or it is part of the call chain, but the frame pointer was not set up properly within the function, so we don’t recognize it.

This way we will always print out the real call chain (plus a few more entries), regardless of whether the frame pointer was set up correctly or not - but in most cases we’ll get the call chain right as well. The entries printed are strictly in stack order, so you can deduce more information from that as well.

# DRM

## Enable extra log in the dmesg

By default, dmesg show just a limited amount which make increase the debug challenge. However, dmesg allows you to enable extra log message by changing the value in the file `/sys/module/drm/parameters/debug`; we have four useful options:

1. You can enable every sort of log message by setting `0xff`, but keep in mind that you going to see thousands of messages. For enabling it just use:
```
echo 0xff > /sys/module/drm/parameters/debug
```

2. For enabling only DRM/KMS logs, you can use:

```
echo 0x02 > /sys/module/drm/parameters/debug
```

3. You can set `0x04` for enabling more logs:

```
echo 0x04 > /sys/module/drm/parameters/debug
```

4. Finally, you can reset to the default by using:

```
echo 0 > /sys/module/drm/parameters/debug
```
