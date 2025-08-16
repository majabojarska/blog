+++
title= "2025 Devlog"
sort_by = "date"
template = "devlog.html"
insert_anchor_links = "heading"

[extra]
comment = true
+++

## 2025-08-15

Finished deploying [ESO](https://external-secrets.io/latest/) with [Bitwarden integrations](https://external-secrets.io/latest/examples/bitwarden/). That Bitwarden guide is severely outdated, so I'm already planning to improve it.

After some initial `NetworkPolicy` shenanigans, I got my first `ExternalSecret` provisioned successfully, from the now Kube-connected Bitwarden Vault. I'm gradually migrating homelab secrets over there.

I'll probably also roll my own Docker image sources (and builds) for the Bitwarden CLI. Currently I've manually built a custom image, based off of [charlesthomas/bitwarden-cli](https://github.com/charlesthomas/bitwarden-cli). I've submitted some improvements to it in the past, but the maintainer generally isn't very responsive. Once I create my own sources from scratch, the image will be exactly how I need it. Can't promise I'll respond quicker, but I'll definitely make time to intake repo activities once or twice per week. Fingers crossed, hehe 🤞.

And finally, since Bitwarden has access to sensitive data, it'd be nice to have the images signed. That's a good opportunity for hands-on experience with [sigstore/cosign](https://github.com/sigstore/cosign).

---

## 2025-08-12

Deploying [External Secrets Operator](https://external-secrets.io/latest/).

---

## 2025-08-11

Deploying the [Arr stack](https://wiki.servarr.com/).

---

## 2025-08-10

Visited [SP6PWT](https://www.qrz.com/db/SP6PWT), the Student Radio Club of the [Wroclaw University of Science and Technology](https://pwr.edu.pl/en/).

{{ image(src="img/devlog/2025-08-10-sp6pwt.webp", alt="SP6PWT radioamateur club", position="center") }}
{{ image(src="img/devlog/2025-08-10-sp6pwr-antennas.webp", alt="SP6PWT radioamateur club — part of the antenna system", position="center") }}

---

## 2025-08-07

Learning about [PostGIS](https://postgis.net/) and [Leaflet](https://leafletjs.com/).

---

## 2025-08-05

Figuring out Intel iGPU passthrough for QEMU VM on PVE, to facilitate hardware video acceleration for my workloads dealing with video processing.

---

## 2025-08-04

For years I've used Spotify, but I'm unhappy about where it's headed as a service. I've decided to explore alternative, networked music player alternatives. This obviously poses a big challenge in terms of the library and content curation. Regardless, I'm going to start purchasing physical CDs from artists that I value, and then rip and ingest into my homelab. As a test run, today I've deployed [Jellyfin](https://jellyfin.org/).

---

## 2025-08-03

Finished building my ham radio power supply, everything is working as intended ♥️.

{{ image(src="img/devlog/2025-08-03-server-psu-test-run.webp", alt="Testing my radio power supply", position="center") }}

I'd still like to do some load testing, to ensure the connectors and wiring are solid, when conducting higher, sustained currents.

---

## 2025-08-02

Went to the local hackerspace to get some change of scenery at the end of the week. Intended to blog a bit while there, but got [nerd-sniped](https://xkcd.com/356/) by someone else's issues with a Wordpress plugin post-migration. While I was troubleshooting, they made a laser-cut depiction of my cat, Luna.

Shout out to [_wowkdigital_](https://www.instagram.com/wowkdigital/)!

{{ image(src="img/devlog/2025-08-02-laser-cut-cats.webp", alt="Laser cut Luna and some other kitty", position="center") }}

---

## 2025-08-01

Printed the enclosure for my ham radio power supply, wiring is in progress.

{{ image(src="img/devlog/2025-08-01-server-psu-wip.webp", alt="Work in progress on wiring my custom ham radio power supply", position="center") }}

---

## 2025-07-31

Xiegu G90 comes with a single-fuse power supply cable (positive rail). That's nice of the manufacturer to do, but it's not enough to protect from certain failure modes. To alleviate this risk, I've added another ([littel](https://www.littelfuse.com/))fuse, to the ground wire. Don't be fooled by the red insulation – the fuse socket came pre-wired and sealed, so I had to cut a piece of the original black cable out 😉.

{{ image(src="img/devlog/2025-07-31-littelfuse-radio-cable.webp", alt="Added a second fuse to my Xiegu G90 power supply cable", position="center") }}

K0NR shared a [nice write-up](https://www.k0nr.com/wordpress/2020/03/one-fuse-or-two/) on when and why you might wanna have two fuses (one on each lead), instead of one.

---

## 2025-07-30

Writing a post on my homelab rack display (continued).

---

## 2025-07-29

Finished rewiring and mapped out the hardware on my modded Petlibro PLAF101.
Luna (the kitty) provided valuable feedback throughout the process.

{{ image(src="img/devlog/2025-07-29-plaf101.webp", alt="Modded Petlibro PLAF101 internals", position="center") }}

---

## 2025-07-28

Figuring out how to properly drive the motor and detect axis rotation increments. Will need to add more modwires, since the motor was definitely connected to the underside pins of the [WBR3](https://developer.tuya.com/en/docs/iot/wbr3-module-datasheet?id=K9dujs2k5nriy), which the [ESP-12E](https://www.snapeda.com/parts/ESP8266-12E/ESP-12E/AI-Thinker/datasheet/) does not have.

{{ image(src="img/devlog/2025-07-28-plaf101-motor-driver.webp", alt="ESPHome logs screenshot depicting button binary sensor events", position="center") }}

---

## 2025-07-27

Flashed ESPHome onto the modded Petlibro PLAF101 board. Configured the basics, mapped out buttons and LEDs.

{{ image(src="img/devlog/2025-07-27-mapping-esphome.webp", alt="ESPHome logs screenshot depicting button binary sensor events", position="center") }}

---

## 2025-07-26

Built a custom [ISP](https://en.wikipedia.org/wiki/In-system_programming) harness for the Petlibro PLAF101 motherboard. Soldered an [ESP-12E](https://www.snapeda.com/parts/ESP8266-12E/ESP-12E/AI-Thinker/datasheet/) module in place of the original [WBR3](https://developer.tuya.com/en/docs/iot/wbr3-module-datasheet?id=K9dujs2k5nriy).

{{ image(src="img/devlog/2025-07-26-plaf101-isp-harness.webp", alt="Custom ISP harness for Petlibro PLAF101 with ESP-12E", position="center") }}

---

## 2025-07-24

Writing a post on how I built my homelab rack display.

---

## 2025-07-22

Finally repaired my ZFS storage pool. Turns out the USB3/SATA adapter was acting up, leading to random IO issues, and the disk eventually going offline.

Replacing the adapter solved the issue. This result is in line with the lack of [SMART](https://en.wikipedia.org/wiki/Self-Monitoring%2C_Analysis_and_Reporting_Technology) errors and no bad blocks detected during full-surface read testing without the adapter. If it was the disk at fault, the failures would have occurred in both environments (regardless of the adapter).

{{ image(src="img/devlog/2025-07-22-usb-sata-controller-chip.webp", alt="USB3/SATA controller chip – JMS578", position="center") }}

The original adapter board has a JMicron [JMS578](https://www.jmicron.com/file/download/1013/JMS578_Product+Brief.pdf). Initial analysis shows that adapters using this chip tend to be flaky in terms of power management, disk enumeration, and SMART support. This can be improved by flashing alternative firmware [[1](https://ralimtek.com/posts/2021/jms578/)]. It's certainly an interesting avenue, but it's not a priority to me at the moment.

**Questions:**

- If it _was_ the JMS578 firmware at fault, why didn't this fail earlier?
- I've seen the same behavior with a different unit of the same exact adapter model, how likely is it that both are defective and exhibiting the same behavior?
- I've had this hardware setup for almost a year now. Perhaps a recent hypervisor's kernel update caused an interoperability regression?

---

## 2025-07-21

- Studying for my ham radio exam.
- Ordered replacement parts for my main virt server:
  - new SSD for the ZFS storage pool,
  - new external 2.5" USB3 disk enclosure.
- Tweaked blog Zola macros to sort recent posts by update date, instead of creation date.

---

## 2025-07-20

- Learning shortwave propagation theory.
- Investigating IO instability issues with one ZFS storage pool disk on my main hypervisor.

---

## 2025-07-19

### Modding the server PSU

Designing a front enclosure for my HSTNS PL-28 server PSU.

{{ image(src="img/devlog/2025-07-19-psu-enclosure.webp", alt="Server PSU enclosure design", position="center") }}

---

## 2025-07-17

Attending an antenna theory workshop at my local radio club ([SP6HACK](https://www.qrz.com/db/SP6HACK)).

---

## 2025-07-16

## Finished the lil' dashboard display

Next up:

- dedicated Grafana dashboard and possibly a [playlist](https://grafana.com/docs/grafana/latest/dashboards/create-manage-playlists/);
- [Fully Kiosk](https://www.fully-kiosk.com/) browser screen dimming and motion detection configuration.

I'll do a full writeup once I complete this project.

{{ image(src="img/devlog/2025-07-16-nokia-g22-on-rack.webp", alt="Nokia G22 modded to a dashboard display, installed on a small 10″ server rack", position="center") }}

---

## 2025-07-15

## Designing a surface mounted holder for the modded phone

I've decided to surface mount this phone to the glass door of my homelab's rack. Working on a design to enclose the whole device (with the mods).

{{ image(src="img/devlog/2025-07-15-nokia-g22-mount.webp", alt="Nokia G22 mount design in progress", position="center") }}

---

## 2025-07-13

## Modding Nokia G22 to operate without a battery

I wanted a compact homelab dashboard, but didn't want to implement a custom embedded solution from scratch. I'm modding an old, defective smartphone to operate solely on external power.

{{ image(src="img/devlog/2025-07-13-modding-nokia-g22.webp", alt="Nokia G22 mount design in progress", position="center") }}

---

## 2025-07-12

### Planning the jailbreak strategy for my Petlibro PLAF101 pet feeder

At first glance, the on-board WBR3 module seems electrically compatible with an ESP8266. I'll pursue this avenue, since it would enable the usage of [ESPHome](https://esphome.io/). Looks like people have [done it before with other devices](https://www.youtube.com/watch?v=d_HpkIiWC3Y)!

{{ image(src="img/devlog/2025-07-12-petlibro-pcb.webp", alt="Xiegu G90 HF transceiver in operation", position="center") }}

### VLC playback issues on Arch Linux

Encountered x264 playback issues in VLC after upgrading on Arch Linux. It appears the [vlc](https://archlinux.org/packages/extra/x86_64/vlc/) package [moved plugins into optional packages](https://bbs.archlinux.org/viewtopic.php?pid=2250756), which were not explicitly required on my system. Namely the ffmpeg backend plugin, which facilitates x264 decoding.

- Minimum viable remediation: `pacman -S vlc-plugin-ffmpeg`.
- All-in-one fix for other plugins: `pacman -S vlc-plugins-all`.

### Xiegu G90 stand

Printed [this stand](https://www.printables.com/make/2730465) for my Xiegu G90:

{{ image(src="img/devlog/2025-07-12-xiegu-g90-stand.webp", alt="Xiegu G90 HF transceiver in operation", position="center") }}

---

## 2025-07-11

### Xiegu G90 Speaker Deflector

Printed a [speaker deflector](https://www.printables.com/model/1064012-xiegu-g90-speaker-deflector) for my Xiegu G90.
{{ image(src="img/devlog/2025-07-11-xiegu-g90-speaker-redirector.webp", alt="Xiegu G90 speaker deflector", position="center") }}

### HF rig planning

Planning the at-home power supply for my HF station.

- During initial tests, the observed current draw at full TX power didn't exceed 4,5A at 13,8V.
- The unit's manual recommends a supply of at least 8A.
- I hoped to use my bench PSU, but I misremembered it having a current capacity of 10A, while it's actually 5A. This technically might be enough, given the measurements, but a 4,5A load is awfully close to the limit, and I'd rather not run the PSU that hot on a regular basis.
- As a long term solution, I've ordered a used 460W server PSU. These are built like tanks and are _very_ cheap – I got mine for just $10. I'm planning to modify it into a 13,8V supply, since HF radios typically operate optimally at that voltage. I'll do a separate write-up on this project once it's finished.

---

## 2025-07-10

Got my first HF transceiver! I'm learning to operate it at my local radioamateur club, since I don't have an antenna rig at home (yet).

{{ image(src="img/devlog/2025-07-11_xiegu_g90_first_run.webp", alt="Xiegu G90 HF transceiver in operation", position="center") }}

---

## 2025-07-08

Reworking my off-site backup strategy for Kubernetes PVCs.

---

## 2025-07-07

~Slamming my head against a wall~ Setting up Nvidia drivers on Arch Linux ([btw](https://knowyourmeme.com/memes/btw-i-use-arch)) for Nvidia RTX4070.

- Turns out my only HDMI output just refuses to work with the [proprietary drivers](https://archlinux.org/packages/extra/x86_64/nvidia/) (`575.64.03-2`), whereas the DisplayPort outputs work just fine.
- Followed the official [Arch Linux guide for Nvidia](https://wiki.archlinux.org/title/NVIDIA), and installed `nvidia`, `nvidia-settings`, `nvidia-utils`.
- Running kernel `linux-lts`, which at the time of writing is `6.15.5-arch1-1`.
- I doubt the HDMI issue is rooted in hardware, since it works just fine in BIOS and when booted with [nouveau](https://nouveau.freedesktop.org/).

---

## 2025-07-06

Observed an issue with my Tailscale setup on OPNsense, where it kept losing its Tailnet connection shortly after startup. No clear indication of failure in the logs. I've been previously using the [FreeBSD ports](https://docs.freebsd.org/en/books/handbook/ports/) implementation and later switched to the recently added, [official OPNsense Tailscale plugin](https://forum.opnsense.org/index.php?topic=44693.0). It's possible that any combination of the following would've sufficed, but here's what I did to remediate:

- ensured the old install is removed from the system and does not attempt to start alongside (possibly conflicting with) the new plugin (like a system service);
- deleted `/var/db/tailscale`;
- reconfigured the Tailscale plugin with a fresh auth key.

---

## 2025-07-05

Fixing/improving the [Apollo](https://github.com/not-matthias/apollo) theme for Zola: [1](https://github.com/not-matthias/apollo/pull/135), [2](https://github.com/not-matthias/apollo/pull/133), [3](https://github.com/not-matthias/apollo/pull/132).

---

## 2025-07-04

Made my first international shortwave radio contact (20m band) 🎉. Direct comms from Wrocław to Spain, over at the [Hackerspace Wrocław](https://www.hswro.org/) club ([SP6HACK](https://www.qrz.com/db/SP6HACK)).

---

## 2025-07-02

Migrating site theme from [Terminimal](https://github.com/pawroman/zola-theme-terminimal) to [Apollo](https://github.com/not-matthias/apollo).

---

## 2025-07-01

Ensuring Kubernetes workloads shut down gracefully, on my single node cluster, during scheduled backups. I'll make a brief post out of this.
