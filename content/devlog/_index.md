+++
title= "2025 Devlog"
sort_by = "date"
template = "devlog.html"
insert_anchor_links = "heading"

[extra]
comment = true
+++

## 2025-07-08

- Reworking my off-site backup strategy for Kubernetes PVCs.

## 2025-07-07

- ~Slamming my head against a wall~ Setting up Nvidia drivers on Linux for Nvidia RTX4070.
  - Turns out my HDMI output (singular) just refuses to work with the [proprietary drivers](https://archlinux.org/packages/extra/x86_64/nvidia/) (`575.64.03-2`), whereas the DisplayPort outputs work just fine. No glitches, no tearing, pure bliss.
  - I doubt the HDMI issue is rooted in hardware, since it works just fine in BIOS and when booted with [nouveau](https://nouveau.freedesktop.org/).

## 2025-07-06

- Observed an issue with my Tailscale setup on OPNsense, where it kept losing its Tailnet connection shortly after startup. No clear indication of failure in the logs. I've been previously using the [FreeBSD ports](https://docs.freebsd.org/en/books/handbook/ports/) implementation and later switched to the recently added, [official OPNsense Tailscale plugin](https://forum.opnsense.org/index.php?topic=44693.0). It's possible that any combination of the following would've sufficed, but here's what I did to remediate:
  - ensured the old install is removed from the system and does not attempt to start alongside (possibly conflicting with) the new plugin (like a system service);
  - deleted `/var/db/tailscale`;
  - reconfigured the Tailscale plugin with a fresh auth key.

## 2025-07-05

- Fixing/improving the [Apollo](https://github.com/not-matthias/apollo) theme for Zola: [1](https://github.com/not-matthias/apollo/pull/135), [2](https://github.com/not-matthias/apollo/pull/133), [3](https://github.com/not-matthias/apollo/pull/132).

## 2025-07-04

- Made my first international shortwave radio contact (20m band) 🎉. Direct comms from Wrocław to Spain, over at the [Hackerspace Wrocław](https://www.hswro.org/) club ([SP6HACK](https://www.qrz.com/db/SP6HACK)).

## 2025-07-02

- Migrating site theme from [Terminimal](https://github.com/pawroman/zola-theme-terminimal) to [Apollo](https://github.com/not-matthias/apollo).

## 2025-07-01

- Ensuring Kubernetes workloads shut down gracefully, on my single node cluster, during scheduled backups. I'll make a brief post out of this.
