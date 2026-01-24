+++
title = "Clock-safe reboots in OpenWrt"
date = 2026-01-24

[taxonomies]
tags = ["openwrt", "linux"]

[extra]
repo_view = true
comment = true
+++

## Context

{{ image(src="img/openwrt-clock-safe-reboot/archer-c6-v2-rear.webp") }}

Around 2019, I've purchased a [TP-Link Archer C6 v2](https://www.tp-link.com/pl/home-networking/wifi-router/archer-c6/v2/). I chose it mainly because of its [OpenWrt support](https://openwrt.org/toh/tp-link/archer_c6_v2), implying good chances for a long life through community-driven maintenance. This has proven true, as it's still receiving firmware updates today, in 2026!

As much as I like this router, I found myself increasingly constrained by its limited compute capabilities. As I expanded my homelab, I could work around many of the challenges it threw my way. For example, I've offloaded the DNS, and configured a VPN gateway on a separate box. The last straw however, was when I moved to a place with a [PPPoE](https://en.wikipedia.org/wiki/Point-to-Point_Protocol_over_Ethernet) uplink. The Archer crumbled under the CPU-intensive processing demands of that protocol, [peaking at around 120mbps of throughput](https://forum.openwrt.org/t/pppoe-too-slow-in-archer-c6/190399). Mind you, I've paid for 300mbps symmetrical [FTTH](https://en.wikipedia.org/wiki/Fiber_to_the_x) at the time, meaning most of my bandwith was going to waste, which I found to be unacceptable. I've eventually migrated most of my networking to a separate x86 box running [OPNsense](https://opnsense.org/), and use the Archer as a minimal wireless access point with VLANs. Since then, I've also upgraded my uplink to 600/300mbps, and can still saturate it at full duplex :grin:.

## Problem statement

As grateful as I am for the OpenWrt devs' work, unfortunately the 5G radio support lacks stability. This was clearly stated in the [device's documentation](https://openwrt.org/toh/tp-link/archer_c6_v2#:~:text=Atheros%20QCA9886%20support%20seems%20to%20be%20buggy). Moreover, whenever the 5G radio goes down, the 2.4G one remains unfazed, happily serving as a fallback. So, the 5G instability is more of an inconvienience, rather than a complete AP blackout. Even so, I prefer to have 5G Wi-Fi most of the time, rather than never, after the radio crashes unrecoverably.

## Workaround

To restore the 5G radio's operation, I've decided to soft-reboot the Archer every morning via a cron job. The unassuming reader might imagine the solution as follows:

```sh
0 5 * * * reboot
```

At least that's what I did, but but implementation poses several issues:

- Cron doesn't know the difference between `05:00:00`, and `05:00:42` – it's still `05:00` (`HH:MM`). The [crontab configuration](https://www.man7.org/linux/man-pages/man5/crontab.5.html) limits the time resolution to minutes (and to months at the opposite extreme).
- The mainboard is **not equipped** with a [real-time clock](https://en.wikipedia.org/wiki/Real-time_clock). In other words, the device's internal time is tracked via software, and so it stops progressing throughout a reboot. _**It might even end up in the past**_. It's actually quite interesting how OpenWrt works around these hardware limitations ([docs](https://openwrt.org/docs/guide-user/base-system/cron?s[]=crontab#:~:text=clock%20gets%20set%20backwards)):

  > In the boot process the clock is initially set by `sysfixtime` to the most recent timestamp of any file found in /etc. The most recent file is possibly a status file or config file, modified maybe 30 seconds before the reboot initiated by cron. So, in the boot process the clock gets set backwards a few seconds to that file's timestamp.

The observable outcome for my setup was as follows:

1. Cron notices it's `05:00`
2. Executes the `reboot` command.
3. The OS boots again, cron starts up.
4. Cron notices it's `05:00` (AGAIN).

And the cycle kept repeating.

{{ image(src="img/openwrt-clock-safe-reboot/meme.webp") }}

Moreover, should a power outage or brownout happen, the clock will end up way back in the past on the next boot.

Taking all of the above into account, here's the final implementation:

```sh
0 5 * * * sleep 120 && touch /etc/banner && reboot
@reboot sleep 120 && ntpd -dnq -p 192.168.1.1
```

Before rebooting at `05:00`, we wait for 2 minutes in order to make sure the "minutes" value changes, which right now is at `00`. Once we're on a "minutes" value larger than `00`, we `touch` a file in `/etc`, which updates its "modified at" attribute to a value later than `05:00`. After reboot, `sysfixtime` reads the previously updated timestamp, effectively avoiding the initially observed boot-loop.

Once we've rebooted, we always sync the system time to an NTP server – in my case the local router. The reason to wait 2 minutes before syncing, is to ensure the device's own networking stack is fully initialized. Otherwise the `ntpd` call might fail intermittently. Syncing to a trusted NTP server right after reboot, remediates the risk of system time drift throughout blackouts.

And that's about it, I've had this configuration running reliably for over 6 years now ☺️. While writing this post, I've also noticed the `sleep`-then-`touch` approach has also been documented in [OpenWrt's own documentation](https://openwrt.org/docs/guide-user/base-system/cron?s[]=crontab#:~:text=touch%20%2Fetc%2Fbanner), which provides more hints on performing time-sensitive operations in OpenWrt.
