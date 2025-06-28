+++
title = "Recovering from disk pressure issues during OPNsense 25.1 major upgrade"
date = 2025-02-03


[taxonomies]
tags = ["homelab", "proxmox", "networking", "opnsense"]

+++

{{ image(src="/img/rescue_opnsense_maj_upgrade/title.webp", alt="Cat yelling at OPNsense logo", position="center", style="border-radius: 1em; width: 100%;") }}

Recently, [OPNsense 25.1 was released](https://forum.opnsense.org/index.php?topic=45460.0) 🎉. Here's how I borked the upgrade and then recovered (with safety belts on).

<!-- more -->

My OPNsense setup already happened to be on the last available `24.X` release, so last evening I sat down to perform the upgrades. The instructions for upgrading from major version 24 say, quote:

> Make sure you have read the release notes and migration guide before attempting this upgrade. Approx. 1000MB will need to be downloaded and require 2000MB of free space to unpack.

I, of course, assumed I had the required 3GB of free space readily available. After all, OPNsense couldn't have gobbled up all of the 16GB of space I gave it upon installation, right? Well, that's where I was wrong. The upgrade got stuck without any notification emitted in the UI, so eventually I've opened the console and was greeted by `out of free space` errors.

Luckily, I've anticipated this risk, and created a backup of the disk image right before starting the upgrade process. This was particularly easy to do, given that I virtualize OPNsense within [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview). I've restored the backup and SSH-ed into the system to check on the storage situation, before attempting to upgrade again.

```bash
root@OPNsense:~ # gpart show
=>      40  33554352  da0  GPT  (16G)
        40    532480    1  efi  (260M)
    532520      1024    2  freebsd-boot  (512K)
    533544       984       - free -  (492K)
    534528  16777216    3  freebsd-swap  (8.0G)
  17311744  16240640    4  freebsd-zfs  (7.7G)
  33552384      2008       - free -  (1.0M)

root@OPNsense:~ # zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zroot  7.50G  6.05G  1.45G        -         -    67%    80%  1.00x    ONLINE  -
```

This is the first time I've ever inspected the partition layout created by the OPNsense installer. It appears that right before the upgrade, OPNsense had 1.45GB of free space on the root partition, which was obviously not enough to handle the procedure. However, what surprised me the most, was the size of the swap partition. It explained where most of the disk space has gone to.

Now, don't get me wrong, swap could certainly come in handy on occasion, but the 4GiB of RAM I've allocated to OPNsense should be more than enough for day-to-day networking operations. As a matter of fact, I've never seen it exceed 1,5GiB (not accounting for [ZFS ARC](https://www.zfshandbook.com/docs/references/glossary/)).

That swap partition size is way overkill for my small homelab, so my first intuition was to shrink it, and reallocate the reclaimed space to the ZFS root partition (`freebsd-zfs`). However, I figured it will be easier to just grow the disk image, and expand the zpool. After all, this OPNsense instance runs exclusively on a dedicated hypervisor, and I still had plenty of unused disk space.

Here's what I did, in order:

1. Shutdown/stop the OPNsense VM.
1. Restore the backup.
1. Resize (grow) the OS disk image. In my case, +2GB would have sufficed just for the upgrade. However, since I'm planning to install some more tools later on, I went with +8GB for good measure.
1. Start the OPNsense VM.
1. SSH into OPNsense as root/superuser. I had to enable root SSH access for this to work, as I had disabled it after installation. Generally it's a good security practice to prohibit root SSH access, but I temporarily needed it here for obvious reasons.
1. Growing the disk might have corrupted your GPT, so check it's health first via `gpart show`. If your GPT shows a `[CORRUPT]` label, attempt to recover it with `gpart recover da0` (`da0` being the target disk device). Ensure you're working with a healthy GPT before proceeding to the next step - `gpart` won't let you mutate the GPT if it's corrupted.
1. Grow the ZFS partition to the max. available space, using [`gpart resize`](<https://man.freebsd.org/cgi/man.cgi?gpart(8)>). Based on the previously gathered info, I've executed `gpart resize -i 4 da0`, `4` being the `freebsd-zfs` partition index, and `da0` being the [GEOM](https://docs.freebsd.org/en/books/handbook/geom/#geom-glabel) device identifier.
1. Ensure the `freebsd-zfs` partition has grown (`gpart show`).
1. Grow the `zroot` zpool to the max. available space on the `freebsd-zfs` partition using [`zpool online`](https://linux.die.net/man/8/zpool) . In my case: `zpool online -e zroot da0p4`. Btw. how cool is it that zpools can expand without any downtime?
1. Ensure the `zroot` pool has grown to use the newly added spac via `zpool list` and optionally `df -h /` .
1. Perform the OPNsense 25.1 upgrade, this time without any issues.

This whole endeavour would've been far more complicated if I couldn't simply grow the disk image. In that case I probably would've gone with the swap shrinking approach.
