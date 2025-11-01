+++
title = "Frozen kernel recipe (5 min cooking time)"
date = 2025-11-01

[taxonomies]
tags = ["linux", "kernel", "sysrq"]
+++

<!-- more -->

> <p style="font-size: 0.75em"> ⚠️ The shell commands listed in this article might irrecoverably corrupt your system and/or data. Run them at your own risk, preferably only in a throwaway virtual machine.</p>

## Freezing the kernel ❄️

Today I started wondering how to reliably trigger a Linux kernel panic, and effectively freeze the entire system.
Fairly quickly, I found the [SysRq kernel module](https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html),
which implements the so-called _magic SysRq key_:

> It is a ‘magical’ key combo you can hit which the kernel will respond to regardless of whatever else it is doing, unless it is completely locked up.

SysRq is disabled by default on most systems. Its individual functions are enabled via a bitmask, with the configuration stored at `/proc/sys/kernel/sysrq`.

The first bit ([LSB](https://en.wikipedia.org/wiki/Bit_numbering#Least_significant_bit)) controls the collective enablement of all SysRq functions \[[1](https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html#how-do-i-enable-the-magic-sysrq-key)\]:

```sh
# Enable all SysRq functions
$ echo 1 | sudo tee /proc/sys/kernel/sysrq
```

Now that's enabled, you need to hit the correct key combo. Per the [kernel guide](https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html#how-do-i-use-the-magic-sysrq-key), the combination is `ALT-SysRq-<command key>` – the `SysRq` key being equivalent to the `Print Screen` key, on most modern keyboards.

Each SysRq function is triggered by a different (pre-defined) command key, with `c` (lower-case) triggering a system crash. However, if you'd prefer to "press" the combo remotely (e.g. via SSH), you can pipe the `<command key>` into `/proc/sysrq-trigger`, for example:

```sh
# Perform a system crash
$ echo c | sudo tee /proc/sysrq-trigger
```

Needless to say, never do this on a host you want to keep running, as it will freeze the system immediately.

## Crash dump inspection 🕵️‍♀️

By default, some systems won't provide much feedback about the crash, except the obvious and evident halt.

Provided that [Kdump](https://wiki.archlinux.org/title/Kdump) (or equivalent) is configured, you'll be able to inspect the kernel crash dump upon the next boot. Here's how you can configure it for:

- [Ubuntu](https://documentation.ubuntu.com/server/how-to/software/kernel-crash-dump/),
- [Arch Linux](https://wiki.archlinux.org/title/Kdump),
- [Fedora](https://fedoraproject.org/wiki/How_to_use_kdump_to_debug_kernel_crashes).

Once Kdump is configured and enabled, enable all SysRq functions and trigger a system crash (just like above). Don't reset the machine immediately, as the crash dump takes a moment to finish, and I found that Kdump by default will reset the system right after. In case that doesn't happen, reset manually once you see a drop in CPU load.

To find the crash dump log, first look into the last boot's kernel logs, where the `kdump` service will have emitted dump info – dmesg log and vmcore locations:

```sh
$ sudo journalctl --boot=-1
# [...]
Nov 01 15:41:51 compooter kdump-tools[613]: Starting kdump-tools:
Nov 01 15:41:51 compooter kdump-tools[618]:  * running makedumpfile --dump-dmesg /proc/vmcore /var/crash/202511011541/dmesg.202511011541
Nov 01 15:41:51 compooter kdump-tools[636]: The dmesg log is saved to /var/crash/202511011541/dmesg.202511011541.
Nov 01 15:41:51 compooter kdump-tools[636]: makedumpfile Completed.
Nov 01 15:41:51 compooter kdump-tools[618]:  * kdump-tools: saved dmesg content in /var/crash/202511011541
Nov 01 15:41:51 compooter kdump-tools[637]: saved dmesg content in /var/crash/202511011541
Nov 01 15:41:51 compooter kdump-tools[618]:  * running makedumpfile -F -c -d 31 /proc/vmcore | compress > /var/crash/202511011541/dump-incomplete
Nov 01 15:41:53 compooter kdump-tools[640]: [574B blob data]
Nov 01 15:41:53 compooter kdump-tools[640]: The dumpfile is saved to STDOUT.
Nov 01 15:41:53 compooter kdump-tools[640]: makedumpfile Completed.
Nov 01 15:41:53 compooter kdump-tools[618]:  * kdump-tools: saved vmcore in /var/crash/202511011541
Nov 01 15:41:53 compooter kdump-tools[645]: saved vmcore in /var/crash/202511011541
Nov 01 15:41:53 compooter kdump-tools[647]: Sat, 01 Nov 2025 15:41:53 +0000
```

Do not confuse the vmcore with the log, as vmcore is a compressed copy of the system memory.

Open the crash dump log:

```sh
$ sudo less /var/crash/202511011541/dmesg.202511011541:
# [...]
[  198.687014] [   T1003] sysrq: Trigger a crash
[  198.687041] [   T1003] Kernel panic - not syncing: sysrq triggered crash
[  198.687050] [   T1003] CPU: 0 PID: 1003 Comm: tee Kdump: loaded Not tainted 6.8.0-87-generic #88-Ubuntu
[  198.687063] [   T1003] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.16.3-0-ga6ed6b701f0a-prebuilt.qemu.org 04/01/2014
[  198.687077] [   T1003] Call Trace:
[  198.687087] [   T1003]  <TASK>
[  198.687103] [   T1003]  dump_stack_lvl+0x27/0xa0
[  198.687119] [   T1003]  dump_stack+0x10/0x20
[  198.687125] [   T1003]  panic+0x366/0x3c0
[  198.687134] [   T1003]  sysrq_handle_crash+0x1a/0x20
[  198.687142] [   T1003]  __handle_sysrq+0xf3/0x290
[  198.687149] [   T1003]  ? apparmor_file_permission+0x8b/0x1b0
[  198.687158] [   T1003]  write_sysrq_trigger+0x62/0x90
[  198.687166] [   T1003]  proc_reg_write+0x6c/0xb0
[  198.687175] [   T1003]  vfs_write+0x100/0x480
[  198.687183] [   T1003]  ? wake_up_process+0x15/0x30
[  198.687191] [   T1003]  ? kick_pool+0x7e/0x110
[  198.687199] [   T1003]  ? _raw_spin_unlock+0xe/0x40
[  198.687208] [   T1003]  ? __queue_work.part.0+0x163/0x3e0
[  198.687216] [   T1003]  ksys_write+0x73/0x100
[  198.687224] [   T1003]  __x64_sys_write+0x19/0x30
[  198.687231] [   T1003]  x64_sys_call+0x7e/0x25a0
[  198.687239] [   T1003]  do_syscall_64+0x7f/0x180
[  198.687264] [   T1003]  ? _raw_spin_unlock_irqrestore+0x11/0x60
[  198.687274] [   T1003]  ? remove_wait_queue+0x47/0x60
[  198.687284] [   T1003]  ? n_tty_write+0x206/0x3a0
[  198.687295] [   T1003]  ? _raw_spin_unlock_irqrestore+0x11/0x60
[  198.687305] [   T1003]  ? __wake_up+0x45/0x70
[  198.687313] [   T1003]  ? iterate_tty_write+0x1a1/0x260
[  198.687321] [   T1003]  ? tty_ldisc_deref+0x16/0x20
[  198.687328] [   T1003]  ? file_tty_write.isra.0+0x9b/0x110
[  198.687336] [   T1003]  ? tty_write+0x11/0x20
[  198.687342] [   T1003]  ? vfs_write+0x2a8/0x480
[  198.687350] [   T1003]  ? ksys_write+0x73/0x100
[  198.687357] [   T1003]  ? arch_exit_to_user_mode_prepare.isra.0+0x1a/0xe0
[  198.687367] [   T1003]  ? syscall_exit_to_user_mode+0x43/0x1e0
[  198.687377] [   T1003]  ? do_syscall_64+0x8c/0x180
[  198.687385] [   T1003]  ? irqentry_exit_to_user_mode+0x38/0x1e0
[  198.687397] [   T1003]  ? irqentry_exit+0x43/0x50
[  198.687404] [   T1003]  ? exc_page_fault+0x94/0x1b0
[  198.687413] [   T1003]  entry_SYSCALL_64_after_hwframe+0x78/0x80
[  198.687422] [   T1003] RIP: 0033:0x74f4db91c5a4
[  198.687450] [   T1003] Code: c7 00 16 00 00 00 b8 ff ff ff ff c3 66 2e 0f 1f 84 00 00 00 00 00 f3 0f 1e fa 80 3d a5 ea 0e 00 00 74 13 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 54 c3 0f 1f 00 55 48 89 e5 48 83 ec 20 48 89
[  198.687484] [   T1003] RSP: 002b:00007ffe400d0d98 EFLAGS: 00000202 ORIG_RAX: 0000000000000001
[  198.687495] [   T1003] RAX: ffffffffffffffda RBX: 0000000000000002 RCX: 000074f4db91c5a4
[  198.687505] [   T1003] RDX: 0000000000000002 RSI: 00007ffe400d0ef0 RDI: 0000000000000003
[  198.687727] [   T1003] RBP: 00007ffe400d0dc0 R08: 0000000000000002 R09: 0000000000000001
[  198.687935] [   T1003] R10: 00000000000001b6 R11: 0000000000000202 R12: 0000000000000002
[  198.688146] [   T1003] R13: 00007ffe400d0ef0 R14: 00005737eab352c0 R15: 0000000000000002
[  198.688352] [   T1003]  </TASK>
```

The crash dump explains what triggered the crash (`sysrq`), alongside the kernel version, hardware type, and a call trace.

Enjoy your frozen kernel 🍨🐧!
