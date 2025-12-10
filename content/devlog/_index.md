+++
title= "2025 Devlog"
sort_by = "date"
template = "devlog.html"
insert_anchor_links = "heading"

[extra]
comment = true
+++

## 2025-12-11

- Deploying [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) and [InfluxDB](https://www.influxdata.com/get-influxdb/). Planning to use them for MQTT integration, mainly geared towards my [Smart Cat Litter Box](https://github.com/majabojarska/smart-cat-litter-box), but will likely expand it to many other MQTT topics.

---

## 2025-12-10

- Had trouble with word movements in [Kitty](https://github.com/kovidgoyal/kitty) on OSX, found [this fix](https://github.com/kovidgoyal/kitty/issues/838#issuecomment-417455803).
- TIL about [YAPP_Box](https://github.com/mrWheel/YAPP_Box), a parametric, OpenSCAD project box framework.
- Designing an enclosure for the mainboard of my [smart-cat-litter-box](https://github.com/majabojarska/smart-cat-litter-box).

---

## 2025-12-09

- Building a [Smart Cat Litter Box](https://github.com/majabojarska/smart-cat-litter-box):
  - Printing [load cell holders](https://www.printables.com/model/157473-load-cell-holder) in order to attach load cells underneath my cat's litterbox :cat:.
  - Assembling the platform.
  - Developing the ESPHome-based firmware.

{{ image(src="img/devlog/2025-12-09-load-cell-holder-prints.webp", alt="", position="center") }}
{{ image(src="img/devlog/2025-12-09-cat-litter-box-platform-underside.webp", alt="", position="center") }}

---

## 2025-12-08

Finished modding the Xiaomi 3H purifier. Reassembled, added to Home Assistant, works like a charm. I took plenty of notes and will do a write-up about this process.

{{ image(src="img/devlog/2025-12-08-esphome-hass-purifier.webp", alt="", position="center") }}

---

## 2025-12-07

Flashing the Xiaomi 3H purifier mainboard with [esphome-miot](https://github.com/dhewg/esphome-miot)

{{ image(src="img/devlog/2025-12-07-esphome-purifier.webp", alt="", position="center") }}

---

## 2025-12-05

Volunteered as an instructor at a soldering workshop for children. Taught basic soldering techniques and safety practices to 4 kids, while assembling a blinking PCB bear. I truly hope it piqued their interest in STEM ✨.

{{ image(src="img/devlog/2025-12-05-lutowanie.webp", alt="", position="center") }}

---

## 2025-12-01

Gave a guest lecture at Politechnika Wrocławska, on the topics of development environments, CI/CD, containerization and application security.

---

## 2025-11-30

Finished disassembling my [Xiaomi Mi Air Purifier 3H](https://www.mi.com/global/support/article/KA-04677/). I'll probably flash it sometime next weekend.

{{ image(src="img/devlog/2025-11-30-xiaomi-3h-purifier-mainboard.webp", alt="", position="center") }}

---

## 2025-11-28

- Migrating my [Tasmota](https://tasmota.github.io/docs/) smart plugs to [ESPHome](https://tasmota.github.io/docs/).
- Made my first QSOs as SP6CAT on the 80m band.

---

## 2025-11-27

Deploying [KEDA](https://keda.sh/) on my homelab cluster. I'll use it with the [Cron scaler](https://keda.sh/docs/2.18/scalers/cron/), in order to scale most of my workloads down to zero replicas during nighttime. The goal here is to reduce power consumption and slightly cut back on the energy bill throughout the year.

TIL that while [CNPG](https://cloudnative-pg.io/documentation/current/) does not support scaling a PostgreSQL cluster to 0 replicas, there is a way to stop the DB's operation safely. It can be done through [declarative hiberation](https://cloudnative-pg.io/documentation/current/declarative_hibernation/). The DB's operation can then be resumed through rehydration (stopping hibernation).

---

## 2025-11-26

- Finally got Zigbee2MQTT working. Still need to finish the Mosquitto deployment for Z2M to not exit on the first failed connection attempt.
- Cleared and flashed my ZigBee dongle with fresh firmware install. Zigbee2MQTT was having issues before that, and now it just works.
  - This will be a cool writeup, adding to my list.

---

## 2025-11-25

- Deploying [Zigbee2MQTT](https://www.zigbee2mqtt.io/) and [Mosquitto](https://mosquitto.org/).
- TIL:
  - [rss-bridge](https://github.com/RSS-Bridge/rss-bridge) – _The RSS feed for websites missing it_.
  - Borgmatic supports intermittently available servers and removable devices by design – [docs link](https://torsion.org/borgmatic/how-to/backup-to-a-removable-drive-or-an-intermittent-server/).

---

## 2025-11-24

Received my first batch of ZigBee devices for home automation. Yet to setup [Zigbee2MQTT](https://www.zigbee2mqtt.io/) and the [Mosquitto](https://mosquitto.org/) broker.

{{ image(src="img/devlog/2025-11-24-env-sensor.webp", alt="", position="center") }}

---

## 2025-11-23

Jailbroke [TYWE2S](https://developer.tuya.com/en/docs/iot/wifie2smodule?id=K9605u79tgxug)-based, Tuya-only smart plugs into local-only, ESP-based ([ESP8285](https://documentation.espressif.com/0a-esp8285_datasheet_en.html)), Tasmota smart plugs. I will be migrating these to [ESPHome](https://esphome.io/) later on, as that's my preferred ecosystem. Tasmota was just the first thing I happened to flash successfully on the day before :grin:.

{{ image(src="img/devlog/2025-11-23-esp02s-plug-soldering.webp", alt="", position="center") }}
{{ image(src="img/devlog/2025-11-23-tasmota-web-ui.webp", alt="", position="center") }}

---

Disassembling my [Xiaomi Mi Air Purifier 3H](https://www.mi.com/global/support/article/KA-04677/) in order to jailbreak the device and allow LAN-only operation via [esphome-miot](https://github.com/dhewg/esphome-miot/wiki/Xiaomi-Mi-Air-Purifier-3H).

This [disassembly video on YouTube](https://www.youtube.com/watch?v=_rC2a6l0M2k) helps a lot, but I got stuck on prying open some of the deeper-seated tabs. Ordered some metal spudgers to get this done in a few weeks time.

---

## 2025-11-22

Building a custom [ESP-02S](https://templates.blakadder.com/ESP-02S.html)/[TYWE2S](https://developer.tuya.com/en/docs/iot/wifie2smodule?id=K9605u79tgxug) flashing adapter. The device is based on [Odani's design](https://www.thingiverse.com/thing:5679533), but I couldn't get the pogo pin housing to print accurrately enough on a 0.4mm nozzle, for the pogo pins to fit properly. Despite many attempts to tweak the model, the resulting holes were either ill-fitting, or not durable enough. The pins would eventually work their way out as the material gradually fatigued, causing the pins to lose contact with the PCB.

Luckily a friend from the [Hackerspace](https://hswro.org/) – who's a CNC machinist – saved the day by machining a fitting equivalent from a harder material.

This was my first hands-on encounter with [pogo pins](https://en.wikipedia.org/wiki/Pogo_pin). They're great, but also quite delicate. Just holding them with pliers, while attempting to press-fit into a housing, can block the movement of the sprint-loaded mechanism, or at least cause it to not glide as smoothly. I'll definitely be getting some of these for my electronics lab.

{{ image(src="img/devlog/2025-11-22-esp02s-adapter.webp", alt="", position="center") }}

I will be making an in-depth post about this, once I take better pictures of the setup.

---

## 2025-11-21

- Figuring out how to flash an [ESP-02S](https://templates.blakadder.com/ESP-02S.html), the same form factor, electrically compatible replacement (for the most part), for a [TYWE2S](https://tasmota.github.io/docs/Pinouts/#tywe2s).
  - This [programming jig by Odani](https://www.thingiverse.com/thing:5679533) seems promising.
- Playing around with [agenix](https://github.com/ryantm/agenix) and [Tailscale](nixos.wiki/wiki/Tailscale) configuration on a NixOS node.

---

## 2025-11-20

- Upgraded Immich to 2.3.1, as 2.2.3 happened to have a regression which cause the browser tab to become unresponsive.
- Configured iGPU PCIe passthrough into my Kubernetes VM, and configured HW acceleration on Jellyfin.

---

## 2025-11-19

I'm now officially a licenced ham radio amateur!

{{ image(src="img/devlog/2025-11-19-callsign-sp6cat.webp", alt="", position="center") }}

Looking forward to making my first QSO 🥳.

---

## 2025-11-15

- Upgraded Immich to 2.2.3, hit issues with startup, reporting errors relating to the pgvecto.rs to VectorChord migration. Followed the [TrueCharts migration guide](https://trueforge.org/truetech/truecharts/charts/stable/immich/migrate-to-vectorchord/) to resolve this issue.
- Wrote down some [notes on ZFS](@/posts/zfs-notes.md)

---

## 2025-11-13

Deployed [stakater/Reloader](https://github.com/stakater/Reloader) to my K3s cluster.

Fixed the network switch sag:

{{ image(src="img/devlog/2025-11-13-network-switch-sag-pre-fix.webp", alt="", position="center") }}
{{ image(src="img/devlog/2025-11-13-network-switch-sag-post-fix.webp", alt="", position="center") }}

---

## 2025-11-12

I've completed my main server's disk pool rework. Ended up doing a ZFS mirror (2 disks) for critical data, and then simple ext4 for data I can afford to lose — re-download or re-rip from CDs. Learned many lessons along the way, most notably:

- ZFS RAID-Z is as slow as a single disk for both reading and writing, as no two disks contain the same data (stripes, parity). Reportedly it can also butcher disks pretty fast.
- [`rclone copy`](https://rclone.org/commands/rclone_copy/) does _not_ persist file permissions and ownership metadata, even if `--metadata` is used (that persists modification times), and even if both the source and target filesystems are the same kind. Use `rsync` when in need of preserving original file ownership and permissions. Had to restore my offsite backup to get the original metadata back.
- PSU issues can manifest as slower disk speeds (slower response times) and intermittent, but recoverable dropouts. Switching from a 65W, to a 135W PSU miraculously solved what I initially suspected to be disk/controller issues. Turns out adding the 3rd disk pushed the smaller PSU right at around its limit.

---

## 2025-11-11

My network switch rackmount is sagging a bit, presumably due to the extended low heat coming off of the machine right below it.
I've desiged a simple frame that wedges right into the existing mount, straightening the whole assembly back up.

{{ image(src="img/devlog/2025-11-11-slicer-preview.webp", alt="", position="center") }}

---

## 2025-11-10

Got a ZigBee coordinator dongle for free (antenna too)!

Need to order some sensors now :grin:.

{{ image(src="img/devlog/2025-11-10-zigbee-coordinator.webp", alt="", position="center") }}

---

## 2025-11-09

- Re-provisioning my main hypervisor's storage to have a PVE-managed zpool.
  - PVE has really nice [documentation](https://pve.proxmox.com/wiki/Performance_Tweaks) on storage performance tweaks.
  - Saving this [ZFS tuning cheat sheet by JRS Systems](https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/) so I can find it more easily in the future.
- TIL about [esphome-miot](https://github.com/dhewg/esphome-miot), I'll be jailbreaking my purifier soon.

---

## 2025-11-08

Backing up my whole `storage` ZFS pool from `kube-01` to the `nas` host, in preparation for a switch from a ZFS mirror (2x1TB) to RAID-Z (3x1TB striped).
The `kube-01` host is a guest on the `pve-01` hypervisor, and was originally created via a lift-n-shift (sort of) from a bare metal installation, and it still manages its own zpool, with the disks mounted via QEMU device passthrough.
I want to move away from this architecture, as it's very limiting:

- The zpool is locked and available to a single host only.
- The guest VM crashes and or/cannot start if a disk goes down. This is sort of good, as no further wear is put on the pool, but I do frequent backups need my service dang it!

So the general idea is to have all zpools in my lab managed by the hypervisor, and expose the datasets as emulated storage devices, managed by Proxmox. The VM only sees a SCSI/SATA interface.

---

## 2025-11-02

- Learning Rust
- Researching o11y options for my Netgear [GS308Ev4](https://www.netgear.com/business/wired/switches/plus/gs308e/) switch:
  - [ha-netgear-plus](https://github.com/ckarrie/ha-netgear-plus) – HomeAssistant integration
  - [py-netgear-plus](https://github.com/foxey/py-netgear-plus) – Python library
  - [netgear-gs308e-exporter](https://github.com/AmoVanB/netgear-gs308e-exporter) – Prometheus exporter
    - Scrapes the web UI, which isn't great, given [NSDP](https://en.wikipedia.org/wiki/Netgear_Switch_Discovery_Protocol) is well-documented by now, and has good library support ([go-nsdp](https://en.wikipedia.org/wiki/Netgear_Switch_Discovery_Protocol)).
  - [prosafe_exporter](https://en.wikipedia.org/wiki/Netgear_Switch_Discovery_Protocol) – actively maintained, written in Rust :crab:

---

## 2025-11-01

TIL:

- About the Linux [SysRq module](https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html).
- Zola supports [Markdown footnotes](https://www.markdownguide.org/extended-syntax/#footnotes).

I'm thinking it would be nice to have calendar-like means of navigation for the devlog. Perhaps something like a GitHub commit graph or a view of the month, with colored blocks on days with a devlog entry, and hyperlinks to the corresponding section on each of the blocks.

---

## 2025-10-31

🕯️👻🕸️🎃🧛

---

## 2025-10-30

Upgraded the firmware on my Netgear GS308Ev4 switch (v1.0.1.3 → v1.0.1.9).

---

## 2025-10-29

TIL about Python [MappingProxyType](https://docs.python.org/3/library/types.html#types.MappingProxyType), as a way to make tidy, actually read-only, dict-like objects.

Wrote a post about it – [Read-only dictionaries with MappingProxyType](@/posts/mapping-proxy-type.md).

---

## 2025-10-26

- Working (pro-bono) on documenting the server infrastructure of [Hackerspace Wrocław](https://hswro.org/).
- Printing yet another [Asometech PD PSU rack mount](https://www.printables.com/model/1301563-asometech-140w-pd-psu-10-rack-mount) for my friend.
- Reading [OPNsense CARP configuration docs](https://docs.opnsense.org/manual/how-tos/carp.html). I'm coming to the conclusion this is too much of a hassle for my homelabbing needs. I'll just stick with keeping backups on a secondary hypervisor, should my main hypervisor fail, bringing the OPNsense guest VM down with it.
- Deployed [n8n](https://n8n.io/) to my homelab.

Here's a cat picture:

{{ image(src="img/devlog/2025-10-26-lunlun.webp", alt="", position="center") }}

---

## 2025-10-25

- TIL [foundObjects/pve-nag-buster](https://github.com/foundObjects/pve-nag-buster/)
- TIL The US military used turd-shaped seismic intrusion detectors, equipped with VHF and/or UHF transmitters [1](https://radiomuseum.org/r/military_seismic_intrusion_detector_sid_radio_transmitter.html).

---

## 2025-10-24

- Bootstrapped my Rust REST API project.
- Watching [Rust Talks by No Boilerplate](https://www.youtube.com/playlist?list=PLZaoyhMXgBzoM9bfb5pyUOT3zjnaDdSEP).

---

## 2025-10-23

Researching Rust web frameworks for a simple backend project. Figured I'd use this as an opportunity to learn some Rust. [tokio-rs/axum](https://github.com/tokio-rs/axum) and [tamasfe/aide](https://github.com/tamasfe/aide) look promising.

---

Deployed [ArchiveBox](https://github.com/ArchiveBox/ArchiveBox) onto my homelab and then removed it after I saw how half-baked this software is.
Great idea, but the implementation needs more work, and the project seems to be barely maintained at this point.

---

## 2025-10-22

TIL OPNsense can not only work in [HA mode](https://docs.opnsense.org/manual/hacarp.html) (fail-over) via [CARP](https://en.wikipedia.org/wiki/Common_Address_Redundancy_Protocol), but it also ensures there's only one [PPP](https://en.wikipedia.org/wiki/Point-to-Point_Protocol) interface actively connected at any given time (the master). I happen to be authenticating into my ISP's uplink via [PPPoE](https://en.wikipedia.org/wiki/Point-to-Point_Protocol_over_Ethernet), which qualifies as a derivative of PPP.

The way I'm currently prepared for a fail-over, is by having a relatively recent clone of my main OPNsense VM on a second hypervisor, sitting offline. It's ready to power up within a couple minutes, in case the current one fails. Reworking this to a setup base on the native HA capabilities will definitely save me some work.

---

Shout out to [stakater/Reloader](https://github.com/stakater/Reloader), which triggers automatic K8s workload rollouts, whenever any of the referenced `Secrets` or `ConfigMaps` are updated.

Per the docs, you just need to add this annotation to your workload (not to be confused with the Pod template):

```yaml
kind: Deployment
metadata:
  name: my-app
  annotations:
    reloader.stakater.com/auto: "true"
```

Supports more granular triggers if needed (kind, name).

## 2025-10-21

TIL about [The Human Only Public License](https://frederic.vanderessen.com/posts/hopl/).

---

TIL about [topolvm](https://github.com/topolvm/topolvm), a persistent local storage CSI plugin, backed by LVM.

- Could be considered an alternative to [rancher/local-path-provisioner](https://github.com/rancher/local-path-provisioner) (LPP).
- It's capacity aware, while LPP is not.
- (Un)fortunately I run ZFS, and don't intend to switch, while topolvm requires LVM2 on top of ext4, xfs, or btrfs.

---

Found this amazing collection of die shot photos over at [happytrees.org](https://happytrees.org/dieshots/). Here's an Intel Xeon MP Gallatin A0 (130nm) ✨:

{{ image(src="img/devlog/2025-10-21-die-shot-happytrees-org.webp", alt="", href="https://happytrees.org/dieshots/File:Intel_Xeon_MP_(Gallatin_A0_130nm)2.jpg", position="center") }}

---

## 2025-10-20

- Deploying [Renovate](https://docs.renovatebot.com/) onto my homelab.

---

## 2025-10-19

- Working on the Helm chart for Bitwarden CLI – [majabojarska/bitwarden-cli-helm](https://github.com/majabojarska/bitwarden-cli-helm).

---

## 2025-10-18

- TIL about [glow](https://github.com/charmbracelet/glow), the CLI Markdown renderer.
- Learned about [this magnificent application of modern technology](https://meow.camera) (_meow_).
- Attended [_End of 10_](https://mobilizon.pl/events/75d89fcd-0af5-4028-a921-0b9cac70468c) at the [Wrocław Hackerspace](https://hswro.org/).
  Helped a stranger continue using their Win 10 laptop by migrating it to Linux. They opted for [Fedora Gnome edition](https://fedoraproject.org/workstation/) (nice choice!).

{{ image(src="img/devlog/2025-10-18-hs-wro.webp", alt="", position="center") }}

---

## 2025-10-17

- **The first release of [bitwarden-cli-docker](https://github.com/majabojarska/bitwarden-cli-docker) is out 🎉!**
- TIL about [asciiflow](asciiflow.com), the ASCII diagramming software.

---

I've been setting up a couple new repos recently, and the UX around adding a GH workflow to required status checks **makes me wanna bite the designer's ankles.**

- The "Add checks" search doesn't list any known (and already executed) GH workflows.
- You need to search for the job's name for it to appear on the list.
- Searching for the workflow's name does NOT work. Meaning, I need to match the exact **job name** starting characters in my search query, in order for the job to appear on the list to select from.

{{ image(src="img/devlog/2025-10-17-spongebob-screaming-inside.webp", alt="", position="center") }}

---

## 2025-10-16

Kicked off work on my [Bitwarden CLI Docker image](https://github.com/majabojarska/bitwarden-cli-docker). A [Helm chart](https://github.com/majabojarska/bitwarden-cli-helm) will follow up.

---

## 2025-10-15

Upgraded to [Immich major version 2](https://github.com/immich-app/immich/releases/tag/v2.0.1).

---

## 2025-10-14

- Upgraded my PVE 8.4 nodes [to major version 9](pve.proxmox.com/wiki/Upgrade_from_8_to_9).
- TIL about [deb822](https://manpages.debian.org/trixie/dpkg-dev/deb822.5.en.html).

---

## 2025-10-12

Recently I've upgraded to [Gnome](https://www.gnome.org/) 49 and one my extensions stopped working. However, it looks like it's working just fine once the extension version validation is disabled. Here's how you can change the config:

```sh
# Read current
dconf write /org/gnome/shell/disable-extension-version-validation

# Disable extension version validation
dconf write /org/gnome/shell/disable-extension-version-validation true
```

---

## 2025-10-09

Went to [KCD Warsaw 2025](https://community.cncf.io/events/details/cncf-kcd-warsaw-presents-kcd-warsaw-2025/).

I can recommend the [KubeEdge](https://kubeedge.io/) presentation (once the recording comes out). I still have some reservations in regard to the suitability of using first-class Kubernetes objects for implementing edge device management (think IoT sensors). However, I'll need to educate myself better on the problem domain, before I'm able to form an opinion. Regardless, it was a good presentation!

{{ image(src="img/devlog/2025-10-09-kcd-warsaw-2025-kubeedge.webp", alt="", position="center") }}

Another talk I found interesting was about [driving a major shift in OpenTelemetry Logs](https://github.com/pellared/otel-logs-talk) by [pellared](https://github.com/pellared). Also TIL about [Slidev](https://sli.dev/) – a markdown-based slide renderer.

{{ image(src="img/devlog/2025-10-09-otel-logs-talk.webp", alt="", position="center") }}

Here's my swag haul 😎

{{ image(src="img/devlog/2025-10-09-kcd-warsaw-2025-swag.webp", alt="", position="center") }}

---

## 2025-10-07

Printed and assembled another one [Asometech PD PSU rack mount](https://www.printables.com/model/1301563-asometech-140w-pd-psu-10-rack-mount) for my friend.

{{ image(src="img/devlog/2025-10-07-print-1.webp", alt="3D printed rack mount for PSU", position="center") }}

---

## 2025-10-01

TIL `git log` supports limiting by date, e.g.:

```sh
git log --since 'Dec 31 2024' --until '2025-05-01'
```

See [commit limiting](https://git-scm.com/docs/git-log#_commit_limiting) docs for more details!

---

## 2025-09-30

Passed my ham radio exam 🎉! The privileges of my license will be the equivalent of the [USA FCC General class](https://www.fcc.gov/wireless/bureau-divisions/mobility-division/amateur-radio-service).

Thinking about callsigns now.

---

## 2025-09-21

Finished my cable hanger. Finally got an easily-accessible place to store cables without tangling them together!

Kudos to _b2vn_ for the [OpenSCAD parametric model](https://www.thingiverse.com/thing:4089728).

{{ image(src="img/devlog/2025-09-21-cable-holder.webp", alt="Cable hanger.", position="center") }}

---

## 2025-09-20

Printing [elements](https://www.thingiverse.com/thing:4089728) for my wall-mounted cable hanger.

---

## 2025-09-18

TIL you can calibrate your oven by using the melting point of sucrose as a temperature reference [[1](https://www.cookingforgeeks.com/blog/posts/the-sweet-way-to-calibrate-your-oven/)].

---

## 2025-09-17

Noticed my Immich instance pulls the smart search ML model sometime after every restart of the ML service Pod. To be precise, the download totals to ~700MB, and is pulled upon receiving the first smart search query, which understandably, requires the ML model to perform the inferencing.

Turns out that the [chart's default](https://github.com/trueforge-org/truecharts/blob/9ee3083da1c07e3b8048e41fc3dcfe78c8b30057/charts/stable/immich/values.yaml#L73) was to mount the ML cache in an [emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) volume, which is fresh (and clean) for every new Pod. I've since replaced it with a proper SSD-backed PVC. Now smart search kicks in way faster after an Immich rollout.

While searching about the ML cache, I found Immich's [recommendations for running as a non-root user](https://immich.app/docs/FAQ/#how-can-i-run-immich-as-a-non-root-user). In my case, matplotlib was defaulting to caching its config to `/tmp/...`, since it couldn't write to `/.config`.

```sh
[09/18/25 21:58:46] WARNING  mkdir -p failed for path /.config/matplotlib:
                             [Errno 13[] Permission denied: '/.config'
[09/18/25 21:58:46] WARNING  Matplotlib created a temporary cache directory at
                             /tmp/matplotlib-urrteabo because there was an issue
                             with the default path (/.config/matplotlib); it is
                             highly recommended to set the MPLCONFIGDIR
                             environment variable to a writable directory, in
                             particular to speed up the import of Matplotlib and
                             to better support multiprocessing.
```

I've got no more startup warnings after applying the recommendations.

```sh
[09/18/25 20:57:53] INFO     Starting gunicorn 23.0.0
[09/18/25 20:57:53] INFO     Listening at: http://[::[]:10003 (8)
[09/18/25 20:57:53] INFO     Using worker: immich_ml.config.CustomUvicornWorker
[09/18/25 20:57:53] INFO     Booting worker with pid: 9
[09/18/25 20:57:58] INFO     Started server process [9[]
[09/18/25 20:57:58] INFO     Waiting for application startup.
[09/18/25 20:57:58] INFO     Created in-memory cache with unloading after 300s
                             of inactivity.
[09/18/25 20:57:58] INFO     Initialized request thread pool with 5 threads.
[09/18/25 20:57:58] INFO     Application startup complete.
```

---

## 2025-09-15

The Tailscale/NixOS issue from [2025-09-07](#2025-09-07) has been [fixed upstream](https://github.com/tailscale/tailscale/issues/16966#issuecomment-3291890894), applied the fix on my infra successfully.

---

## 2025-09-14

Fixing the stuck lidar drive in my robot vacuum. I'll make a short post out of this.

{{ image(src="img/devlog/2025-09-14-lidar.webp", alt="Lidar unit in Roborock Q7 Max.", position="center") }}

---

## 2025-09-11

- Improving my [Homepage](https://gethomepage.dev/) dashboard.
- Studying for the ham radio exam.
- Should I try switching to Neovim 🤔?

---

## 2025-09-10

- Quick homelab maintenance, updates.

---

## 2025-09-09

- Studying for my ham radio exam. It's just a couple weeks away!
- TIL the `CIVIL` mnemonic for phase differences between current and voltage, in capacitive and inductive resonant circuits. See [this video (16:55)](https://youtu.be/yEG6pKUdIlg?si=2DZxEu1hNm9Ih3CV&t=1015) from EEVblog Dave. TL;DR:
  - In capacitive (`C`) resonant circuits (`I`), current leads voltage (`V`).
  - Voltage (`V`) leads current (`I`) in inductive (`L`) resonant circuits.

---

## 2025-09-08

- Read this publication: [Federated Systems – Jeremy Rubin (2015)](https://www.mit.edu/~jlrubin/public/pdfs/federation.pdf). Here are my key takeaways:
  - Federated systems are fully recursive. Each federated system can contain (be composed of) other federated systems.
  - Composability is king. Aiming to solve a single problem helps make the system composable. See DNS, HTTP, SMTP, XMPP.
  - Solve large-scale problems centrally, and federate the small-scale ones.
  - Customizability is desirable, but can break compatibility. If needed, seek to make it composable, and constrain the system to prevent strong divergence between clients.
  - Interoperability is key, but it's possible to overdo it (_Friendica_ vs _diaspora\*_).
  - Don't rely on the users' generosity to keep the system afloat, because it can abruptly run short. Have a business model for providers.
  - McDonald's is actually a federated system (lol).

---

## 2025-09-07

Wee infra maintenance. Pulled in the in-flight patch for current Tailscale kernel regression issues in NixOS – [#16966](https://github.com/tailscale/tailscale/issues/16966#issuecomment-3239543750):

```nix
  nixpkgs.overlays = [(_: prev: {
    tailscale = prev.tailscale.overrideAttrs (old: {
      checkFlags =
        builtins.map (
          flag:
            if prev.lib.hasPrefix "-skip=" flag
            then flag + "|^TestGetList$|^TestIgnoreLocallyBoundPorts$|^TestPoller$"
            else flag
        )
        old.checkFlags;
    });
  })];
```

---

## 2025-09-06

- Troubleshooting homepage service/widget state issues. Turns out there's a known limitation in regard to service/group name uniqueness – [discussion #5756](https://github.com/gethomepage/homepage/discussions/5756).
- [TIL](https://dynomight.net/links-3/#:~:text=%286%29%20Text%20fragment%20links) you can link to _any_ text on _any_ page, and (most) modern browsers support it! This is a web feature called ["Text fragments"](https://developer.mozilla.org/en-US/docs/Web/URI/Reference/Fragment/Text_fragments). You can even define a suffix/prefix to constrain the query with 🤯!
- > [Optimize for thinking](https://dynomight.net/paper/#:~:text=Optimize%20for%20thinking)

---

## 2025-09-05

Performed stress testing of my [ham radio PSU](@/posts/ham-radio-psu.md) under thermal vision. Used a 50Ω dummy load to sink the transceiver's antenna output.

{{ image(src="img/devlog/2025-09-05-thermal-dummy-load.webp", alt="Thermal vision view of dummy antenna load.", position="center") }}

The PSU performed well under a continuous ~6A load. Funnily enough, the bright spot on the photo below is a 510Ω resistor, dropping the voltage for the standby status LED. It drops ~10V at 20mA, resulting in 0,2W of total power dissipated as heat. Since it's a 1/4W resistor, it's operating within spec, and the temperature eventually stabilizes around 54°C in room temperature conditions, which is totally safe.

{{ image(src="img/devlog/2025-09-05-thermal-psu.webp", alt="Thermal vision view of my diy ham radio PSU.", position="center") }}

---

## 2025-09-04

- Rolled out [FreshRSS](https://www.freshrss.org/) and [Miniflux](https://miniflux.app/) to my homelab. I'll be trying both out and will choose the one I like better by next Sunday.
- Creating graphics for my hackerspace's next SSTV radiosonde event. This one will be themed around the beloved cat that hangs around the workshop, named Komódka (after Commodore 64). Learned a lot of Inkscape today, it'sw pretty neat!
- Trying to figure out why my Calibre-web instance sometimes just fails to ingest a book.

{{ image(src="img/devlog/2025-09-04-komodka-sstv.webp", alt="Komódka SSTV image.", position="center") }}

---

## 2025-09-03

Trying out the [Nagoya UT-108UV](https://www.nagoya.com.tw/en/product-384544/UT-108UV.html) antenna on 2m and 70cm bands.

---

## 2025-09-02

Working on the [ham radio PSU post](@/posts/ham-radio-psu.md).

---

## 2025-08-31

Playing around with [SSTV](https://en.wikipedia.org/wiki/Slow-scan_television). Only at the audio level for now, yet to transmit the first Luna (the cat) on the amateur bands.

{{ image(src="img/devlog/2025-08-31-luna-sstv-android.webp", alt="Luna pondering upon the network cable tester.", position="center") }}

---

## 2025-08-30

- Doing a bunch of homelab maintenance tasks – checks, backups, upgrades.
- Upgrading OpenWRT on my [TP-Link Archer C6 v2](https://openwrt.org/toh/tp-link/archer_c6_v2), from old stable [23.05](https://openwrt.org/releases/23.05/start) to [24.10](https://openwrt.org/releases/24.10/start). Reportedly, the 5GHz radio issues are fixed with [24.10.2](https://openwrt.org/releases/24.10/notes-24.10.2).
- Hit this [tailscale issue (#16966)](https://github.com/tailscale/tailscale/issues/16966) on my NixOS setup. Kudos to [@tetov](https://github.com/tetov) for providing [a workaround](https://github.com/tailscale/tailscale/issues/16966#issuecomment-3239543750).

{{ image(src="img/devlog/2025-08-30-rj45-cable-tester.webp", alt="Luna pondering upon the network cable tester.", position="center") }}

---

## 2025-08-29

Spent the day operating the [HF0CEBULA](https://www.qrz.com/db/HF0CEBULA) special event ham radio station, which was active for the duration of [Cebula Camp 2025](https://cebula.camp/en). I've made approx. 20 QSOs on the 2m band, which I'm quite proud of – the station made even more QSOs in total that day. Ironically, I think there was more interest in the station's operation (and ham radio in general) on-site from the attendees, than remotely, over the ham frequencies. Good times!

{{ image(src="img/devlog/2025-08-29-cebulacamp.webp", alt="HF0CEBULA special event station.", position="center") }}

---

## 2025-08-27

- Reading about the music analysis and clustering algorithms in [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI).
- Connecting my cloud VPS to the homelab via Tailscale.
- Deploying a fresh instance of Prometheus and Grafana in the cloud. Used to have these on my K3s cluster, but it's not the best design in case of K3s issues.

## 2025-08-26

Spent the afternoon on 20/40M bands at the SP6PWT radio club. Operated the [Yaesu FT-710](https://www.yaesu.com/product-detail.aspx?Model=FT-710&CatName=HF%20Transceivers/Amplifiers). Made a couple successful QSOs: `IU1RVT`, `SO8DON`, `ED5FS8`, `IT9DOR`.

{{ image(src="img/devlog/2025-08-26-sp6pwt.webp", alt="Making shortwave contacts at the SP6PWT radio club.", position="center") }}

## 2025-08-24

Today it's just logs, without the dev.

{{ image(src="img/devlog/2025-08-24-forest-logs.webp", alt="Wooden logs in the mountains.", position="center") }}

## 2025-08-23

- TIL about [exportify](https://github.com/watsonbox/exportify), an export/backup tool for Spotify playlists.
- Troubleshooting invalid behavior of the [Tailscale widget](https://gethomepage.dev/widgets/services/tailscale/), when multiple instances are spawned in the same group.
- Filed an issue with the Homepage project, regarding documentation site breakage – [discussions/5707](https://github.com/gethomepage/homepage/discussions/5707).

---

## 2025-08-21

Playing around with [Homepage](https://github.com/gethomepage/homepage) sources. Experimenting with feature enhancements for the [Tailscale widget](https://gethomepage.dev/widgets/services/tailscale/).

---

## 2025-08-20

- Made a small docs contrib to the Truecharts Homepage Helm chart — [#38666](https://github.com/trueforge-org/truecharts/pull/38666)
- Adding even more pretty lil' widgets to my Homepage instance.

In case you wondered, here's how you can escape environment variable interpolation in [Homepage configs](https://gethomepage.dev/installation/docker/#using-environment-secrets), within Helm manifests:

```yaml
              - Immich:
                  icon: immich.svg
                  href: {{`"{{HOMEPAGE_VAR_IMMICH_URL}}"`}}
                  widget:
                    type: immich
                    url: {{`"{{HOMEPAGE_VAR_IMMICH_URL}}"`}}
                    key: {{`"{{HOMEPAGE_VAR_IMMICH_API_TOKEN}}"`}}
                    version: 2
```

---

## 2025-08-19

- Reworking my [NixOS](https://nixos.wiki/) [iptable](https://linux.die.net/man/8/iptables) firewall rules to accomodate my Kubernetes [metrics-server](https://github.com/kubernetes-sigs/metrics-server) with [Flannel](https://github.com/flannel-io/flannel), on top of [K3s](https://k3s.io/), without the built-in, [kube-router](https://www.kube-router.io/) based [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/) handling.

---

## 2025-08-18

- Adding pretty lil' widgets to my [Homepage](https://gethomepage.dev/) instance.
- Learned about this cool dot matrix printer font, the [EPSON MX-80](https://mw.rat.bz/MX-80/) — courtesy of Michael Walden.
- Learned about ESO, the project which I've recently deployed to my homelab, is experiencing serious [team capacity issues](https://github.com/external-secrets/external-secrets/issues/5084). I'm seriously considering signing up as a maintainer, but still need to weigh my priorities.

---

## 2025-08-17

- Figured out why my K8s metrics server workload started failing recently — this will be a nice short post.
- Deploying [Homepage](https://gethomepage.dev/).
- Deploying Grafana, Prometheus and Node Exporter to my VPS (on [NixOS](https://nixos.org/)). Kudos to [Xe Iaso](https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/) for this guide!

---

## 2025-08-16

- Migrated my Kubernetes secrets to [ExternalSecrets](https://external-secrets.io/latest/api/externalsecret/) (tokens, passwords, logins, etc.).
- Added the [Flannel CNI](https://github.com/flannel-io/flannel) to my Kubernetes cluster.
- Figuring out a better approach to homelab monitoring.
  - I'll probably migrate Prometheus and Grafana off of the homelab, onto the cloud VPS. That's where I plan to host my alerting system, so it makes sense to keep things close.
  - [metrics-server](https://github.com/kubernetes-sigs/metrics-server) is acting up on my cluster, looking into it.
- Added some nicer CSS transitions to the blog.

---

## 2025-08-15

Finished deploying [ESO](https://external-secrets.io/latest/) with [Bitwarden integrations](https://external-secrets.io/latest/examples/bitwarden/). That Bitwarden guide is severely outdated, so I'm already planning to improve it.

After some initial `NetworkPolicy` shenanigans, I got my first `ExternalSecret` provisioned successfully, from the now Kube-connected Bitwarden Vault. I'm gradually migrating homelab secrets over there.

{{ image(src="img/devlog/2025-08-16-eso-css.webp", alt="ClusterSecretStore K8s resource list", position="center") }}

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
