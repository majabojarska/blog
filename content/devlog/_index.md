+++
title= "2025 Devlog"
sort_by = "date"
template = "devlog.html"
insert_anchor_links = "heading"

[extra]
comment = true
+++

<<<<<<< Updated upstream
=======
## 2025-07-12

- Printed [this Xiegu G90 stand](https://www.printables.com/model/119835-xiegu-g90-stand-remixed-to-be-stronger-and-sleeker)

  {{ image(src="/img/404.webp", alt="3D printed stand for Xiegu G90", position="center") }}

>>>>>>> Stashed changes
## 2025-07-11

- Printing some components for my Xiegu G90 to make it more user-friendly, namely:
  - [speaker redirector](https://www.printables.com/model/1064012-xiegu-g90-speaker-deflector) – the unit's speaker is directed upwards, which is not ideal;
  - foldable stand – yet to decide on the exact solution.
- Planning the at-home power supply for my HF transceiver.
  - During initial tests, the observed current draw at full TX power didn't exceed 4,5A at 13,8V.
  - The unit's manual recommends a supply of at least 8A.
  - I hoped to use my bench PSU, but I misremembered it having a current capacity of 10A, while it's actually 5A. This technically might be enough, given the measurements, but a 4,5A load is awfully close to the limit, and I'd rather not run the PSU that hot on a regular basis.
  - As a long term solution, I've ordered a used 460W server PSU. These are built like tanks and are _very_ cheap – I got mine for just $10. I'm planning to modify it into a 13,8V supply, since HF radios typically operate optimally at that voltage. I'll do a separate write-up on this project once it's finished.

## 2025-07-10

- Got my first HF transceiver! I'm learning to operate it at my local radioamateur club, since I don't have an antenna rig at home (yet).

  {{ image(src="/img/devlog/2025-07-11_xiegu_g90_first_run.webp", alt="Xiegu G90 HF transceiver in operation", position="center") }}

## 2025-07-08

- Reworking my off-site backup strategy for Kubernetes PVCs.

## 2025-07-07

- ~Slamming my head against a wall~ Setting up Nvidia drivers on Arch Linux ([btw](https://knowyourmeme.com/memes/btw-i-use-arch)) for Nvidia RTX4070.
  - Turns out my only HDMI output just refuses to work with the [proprietary drivers](https://archlinux.org/packages/extra/x86_64/nvidia/) (`575.64.03-2`), whereas the DisplayPort outputs work just fine.
  - Followed the official [Arch Linux guide for Nvidia](https://wiki.archlinux.org/title/NVIDIA), and installed `nvidia`, `nvidia-settings`, `nvidia-utils`.
  - Running kernel `linux-lts`, which at the time of writing is `6.15.5-arch1-1`.
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
