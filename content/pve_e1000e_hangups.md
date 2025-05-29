+++
title = "Solving Intel NIC hangups on Proxmox VE 8.4-1"
date = 2025-05-29


[taxonomies]
tags = ["proxmox", "networking", "linux"]

+++

{{ image(src="/img/pve_e1000e_hangups/souls_title.webp", alt="Image saying detected hardware unit hang in capital letters, stylized as a Dark Souls III death caption.",
         position="center", style="border-radius: 8px; width: 100%;") }}


Recently I've been seeing my NAS' network interface go down unrecoverably (i.e. until a reboot). The first time I've observed this, I happened to be running some OS upgrades, so I brushed it off as a one-time, wonky interaction with the network interface. However, I've noticed it kept happening from time to time, so I started wondering about the common denominator of all of these events. It would only happen during high network throughput events, which saturated the gigabit link in a sustained fashion, like dumping backups or pulling several GBs of packages. On the other hand, the issue would never reproduce during light loads (network-wise), like tweaking configs over SSH (even during long-lived sessions).

<!-- more -->

## The environment

{{ image(src="/img/pve_e1000e_hangups/environment.svg", alt="Vacuum tube with powered on heater filaments",
         position="center", style="border-radius: 8px; width: 75%; padding: 16px;") }}

The suspected NAS host is a NixOS VM running on top of [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview), which implies there's some virtual network complexity at play. To briefly explain the infrastructure, the VMs are networked to the hypervisor's physical interface via a [linux bridge interface](https://pve.proxmox.com/wiki/Network_Configuration). Logically, it's like a layer 2 switch, allowing to connect multiple virtual NICs, via physical hypervisor interfaces, to the underlying lab network.

## Side note about virtualization

These NIC hangups quickly sent me down memory lane. Circa 2021, I was working on building out virtualization infrastructure for testing an embedded Linux device's software in its early stages. The crux of it was that it had several, multi-gigabit NICs, alongside some other physical interfaces, highly sensitive to timing. If I recall correctly, we did eventually have an early hardware prototype in the lab, but it wasn't fit for integrating into a CI pipeline, let alone doing so at scale. The challenge with virtualization here, was that the guest OS was a custom-built Yocto image, designed for the _real thing_.

Generally speaking, virtualizing a hardware-oriented device always calls for some trade-offs. One cannot simply run nor test everything in a VM, since there's a boundary, beyond which you can't play pretend anymore (performance or inability to virtualize), or the pretending just stops being reasonably cost-effective (cheaper to use hardware, than build out custom tools enabling further virtualization). For example:

- Mocking DMI table info? Easy.
- Setting up disks for a software RAID? Easy.
- Passing through some USB devices? Easy.
- Getting the virtual NICs to behave exactly the same way as your SFP modules of choice, in a way that's compatible with the purpose-built software? [What color do you want your dragon?](https://knowyourmeme.com/photos/1052192-for-christmas-i-want-a-dragon). 

Software-side accommodations eventually need to be considered, e.g. flags that inform the kernel it needs to boot with a slightly different configuration. Likewise, services might need to be mocked, or disabled altogether, due to the inability to satisfy certain hardware requirements. This implies there are some  limitations to virtualized testing environments, but it's often still far better than nothing, when hardware units are scarce.

Now, back on topic!

## Finding the root cause

I happen to have another NixOS machine with an Intel NIC in my lab. It runs bare-metal with the same network configuration, without any hiccups whatsoever, so naturally I suspected the virtual NIC to be the culprit. However, this specific situation was different. Not only the VM, but the PVE hypervisor too, were becoming unreachable — simultaneously, like clockwork. Any attempt to reach the PVE hypervisor, let alone log into the console, resulted in connection failures. This behavior indicated it wasn't the VM's NIC, but rather the hypervisor's NIC that was failing, causing the VM to go dark as a symptom of the broader issue.

By this point, I could reproduce the failure reliably, by saturating the NAS interface with [iperf](https://iperf.fr/), with the other end of the link running on my router. In retrospect, saturating the hypervisor's interface might've been enough, but at the time I wanted to synthetically simulate the naturally occuring traffic flow _through_ the NAS. Once the hypervisor's interface was trashed, I gracefully power cycled the machine, and started looking at kernel logs from the previous boot:

```sh
journalctl --dmesg --boot -1
```

Looking towards the end, I found a flurry of repeating errors, relating to the [`e1000e` kernel module](https://www.intel.com/content/www/us/en/support/articles/000005480/ethernet-products.html):

```raw
May 25 15:23:30 pve-02 kernel: e1000e 0000:00:19.0 eno1: Detected Hardware Unit Hang:
                                 TDH                  <61>
                                 TDT                  <90>
                                 next_to_use          <90>
                                 next_to_clean        <60>
                               buffer_info[next_to_clean]:
                                 time_stamp           <1000936a9>
                                 next_to_watch        <61>
                                 jiffies              <1000ca540>
                                 next_to_watch.status <0>
                               MAC Status             <80083>
                               PHY Status             <796d>
                               PHY 1000BASE-T Status  <3800>
                               PHY Extended Status    <3000>
                               PCI Status             <10>

######## SNIP ########

May 25 15:23:32 pve-02 systemd-shutdown[1]: Syncing filesystems and block devices.
May 25 15:23:32 pve-02 systemd-shutdown[1]: Sending SIGTERM to remaining processes...
May 25 15:23:32 pve-02 systemd-journald[339]: Received SIGTERM from PID 1 (systemd-shutdow).
```

Searching the web for that error shows it's likely caused by a fault in TCP checksum offloading.

Before proceeding, let's compare the NICs and the corresponding configurations across my Linux servers, just to make sure.

### NIC driver/configuration comparison

Here's how I grabbed all of the necessary information from a single host:

```sh
# Dump NIC kernel driver and firmware info
root@pve-02:~# ethtool -i eno1

driver: e1000e
version: 6.8.12-10-pve
firmware-version: 0.13-4
expansion-rom-version:
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

# Dump PCI devices' info. Requires the controller entry to be found manually.
root@pve-02:~# lspci -nn -v

######## SNIP ########
00:19.0 Ethernet controller [0200]: Intel Corporation Ethernet Connection I217-LM [8086:153a] (rev 04)
        DeviceName:  Onboard LAN
        Subsystem: Dell Ethernet Connection I217-LM [1028:05a4]
        Flags: bus master, fast devsel, latency 0, IRQ 28, IOMMU group 5
        Memory at f7c00000 (32-bit, non-prefetchable) [size=128K]
        Memory at f7c3d000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at f080 [size=32]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [e0] PCI Advanced Features
        Kernel driver in use: e1000e
        Kernel modules: e1000e
######## SNIP ########
```

| Host     | Model              | `e1000e` driver version | Working properly? |
| -------- | ------------------ | ----------------------- | ----------------- |
| `m920q`  | `I219-LM (rev 10)` | `6.12.30`               | ✅                |
| `pve-03` | `I219-V`           | `6.8.12-10-pve`         | ✅                |
| `pve-02` | `I217-LM (rev 04)` | `6.8.12-10-pve`         | ❌                |

The driver version is essentially the OS kernel version, visibly running PVE kernels on the PVE hosts.

I've also retrieved the offload feature enablement status across the same hosts, using:

```sh
ethtool --show-features <iface_name> | grep offload
```

| feature \ host                 | `m920q`       | `pve-03`      | `pve-02`      |
| ------------------------------ | ------------- | ------------- | ------------- |
| `tcp-segmentation-offload`     | `on`          | `off`         | `on`          |
| `generic-segmentation-offload` | `on`          | `on`          | `on`          |
| `generic-receive-offload`      | `on`          | `on`          | `on`          |
| `large-receive-offload`        | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `rx-vlan-offload`              | `on`          | `on`          | `on`          |
| `tx-vlan-offload`              | `on`          | `on`          | `on`          |
| `l2-fwd-offload`               | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `hw-tc-offload`                | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `esp-hw-offload`               | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `esp-tx-csum-hw-offload`       | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `rx-udp_tunnel-port-offload`   | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `tls-hw-tx-offload`            | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `tls-hw-rx-offload`            | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `macsec-hw-offload`            | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `hsr-tag-ins-offload`          | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `hsr-tag-rm-offload`           | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `hsr-fwd-offload`              | `off [fixed]` | `off [fixed]` | `off [fixed]` |
| `hsr-dup-offload`              | `off [fixed]` | `off [fixed]` | `off [fixed]` |

Given that `pve-02` and `pve-03` run the same `e1000e` driver version, I'm now suspecting it's the `tcp-segmentation-offload` feature that's causing the NIC to fail — that's the only difference in the offload feature configuration between the two hosts. But still, those are two different controllers, so more (different) tweaking might be needed.

## The solution

Here are some potential workarounds I found in relation to my observations:

- [disabling the C1E power state via BIOS;](https://superuser.com/questions/1270723/how-to-fix-eth0-detected-hardware-unit-hang-in-debian-9)
- [disabling NIC TCP checksum offloading;](https://serverfault.com/questions/616485/e1000e-reset-adapter-unexpectedly-detected-hardware-unit-hang)
- flashing the NIC with a patched firmware update.

All in all I'd prefer not to disable features beneficial to performance and/or the system's efficency. Disabling [TCP checksum offloading](https://wiki.wireshark.org/CaptureSetup/Offloading) would lead to increased CPU overhead. [Disabling C1E might impact core wake up times](https://www.intel.com/content/www/us/en/support/articles/000006619/processors/intel-core-processors.html), leading to worse general performance. However, Intel doesn't seem to have released any firmware patches for this specific NIC before EOL, so I've opted to disable the offending offloading features.

Let's do this piecemeal and start by disabling `tso` first.

```sh
ethtool --features eno1 tso off
```

TODO: finish below

- figure out if disabling just TSO is enough. Otherwise disable all offloading feats.

---

It's worth noting the relevant offloading features need to be disabled every time the interface is enabled. On Debian-based systems, this can be achieved using the `post-up` directive in `/etc/network/interfaces`, for example:

```diff
auto lo
iface lo inet loopback

iface eno1 inet manual
>         post-up ethtool --features eno1 tso off

auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
```

The remainder of the offloading features don't need to be explicitly disabled, since they're unsupported (`off [fixed]`).

---

That's all for today. Hope you found this helpful!

The title image was generated with this
[FromSoftware image macro creator](https://rezuaq.be/new-area/image-creator/).

---

BEFORE

```sh
root@pve-03:~# ethtool -i enp0s31f6
driver: e1000e
version: 6.8.12-4-pve
firmware-version: 0.8-4
expansion-rom-version:
bus-info: 0000:00:1f.6
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

root@pve-03:~# lspci -nn -v
######## SNIP ########
00:1f.6 Ethernet controller [0200]: Intel Corporation Ethernet Connection (2) I219-V [8086:15b8]
        Subsystem: Lenovo Ethernet Connection (2) I219-V [17aa:3111]
        Flags: bus master, fast devsel, latency 0, IRQ 123, IOMMU group 5
        Memory at f7100000 (32-bit, non-prefetchable) [size=128K]
        Capabilities: [c8] Power Management version 3
        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [e0] PCI Advanced Features
        Kernel driver in use: e1000e
        Kernel modules: e1000e
######## SNIP ########

root@pve-03:~# ethtool --show-features enp0s31f6 | grep offload
tcp-segmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
l2-fwd-offload: off [fixed]
hw-tc-offload: off [fixed]
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]
rx-udp_tunnel-port-offload: off [fixed]
tls-hw-tx-offload: off [fixed]
tls-hw-rx-offload: off [fixed]
macsec-hw-offload: off [fixed]
hsr-tag-ins-offload: off [fixed]
hsr-tag-rm-offload: off [fixed]
hsr-fwd-offload: off [fixed]
hsr-dup-offload: off [fixed]

```

```sh
root@pve-02:~# ethtool -i eno1
driver: e1000e
version: 6.8.12-10-pve
firmware-version: 0.13-4
expansion-rom-version:
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes


root@pve-02:~# lspci -nn -v
######## SNIP ########
00:19.0 Ethernet controller [0200]: Intel Corporation Ethernet Connection I217-LM [8086:153a] (rev 04)
        DeviceName:  Onboard LAN
        Subsystem: Dell Ethernet Connection I217-LM [1028:05a4]
        Flags: bus master, fast devsel, latency 0, IRQ 28, IOMMU group 5
        Memory at f7c00000 (32-bit, non-prefetchable) [size=128K]
        Memory at f7c3d000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at f080 [size=32]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
        Capabilities: [e0] PCI Advanced Features
        Kernel driver in use: e1000e
        Kernel modules: e1000e
######## SNIP ########


root@pve-02:~# ethtool --show-features eno1 | grep offload
tcp-segmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
l2-fwd-offload: off [fixed]
hw-tc-offload: off [fixed]
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]
rx-udp_tunnel-port-offload: off [fixed]
tls-hw-tx-offload: off [fixed]
tls-hw-rx-offload: off [fixed]
macsec-hw-offload: off [fixed]
hsr-tag-ins-offload: off [fixed]
hsr-tag-rm-offload: off [fixed]
hsr-fwd-offload: off [fixed]
hsr-dup-offload: off [fixed]
```

```sh

# m920q
00:1f.6 Ethernet controller [0200]: Intel Corporation Ethernet Connection (7) I219-LM [8086:15bb] (rev 10)
        DeviceName: Onboard - Ethernet
        Subsystem: Lenovo Device [17aa:3136]
        Flags: bus master, fast devsel, latency 0, IRQ 138
        Memory at cc200000 (32-bit, non-prefetchable) [size=128K]
        Capabilities: <access denied>
        Kernel driver in use: e1000e
        Kernel modules: e1000e


ethtool -i eno1

driver: e1000e
version: 6.12.30
firmware-version: 0.5-4
expansion-rom-version:
bus-info: 0000:00:1f.6
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

[nix-shell:~]$ ethtool --show-features eno1 | grep offload
tcp-segmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
l2-fwd-offload: off [fixed]
hw-tc-offload: off [fixed]
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]
rx-udp_tunnel-port-offload: off [fixed]
tls-hw-tx-offload: off [fixed]
tls-hw-rx-offload: off [fixed]
macsec-hw-offload: off [fixed]
hsr-tag-ins-offload: off [fixed]
hsr-tag-rm-offload: off [fixed]
hsr-fwd-offload: off [fixed]
hsr-dup-offload: off [fixed]

```

Disable offloading opts on post-up

```sh
auto lo
iface lo inet loopback

iface eno1 inet manual
        post-up ethtool --features eno1 gso off gro off tso off tx off rx off rxvlan off txvlan off

auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
```

AFTER

````sh
root@pve-02:~# ethtool --show-features eno1 | grep offload
tcp-segmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off [fixed]
rx-vlan-offload: off
tx-vlan-offload: off
l2-fwd-offload: off [fixed]
hw-tc-offload: off [fixed]
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]
rx-udp_tunnel-port-offload: off [fixed]
tls-hw-tx-offload: off [fixed]
tls-hw-rx-offload: off [fixed]
macsec-hw-offload: off [fixed]
hsr-tag-ins-offload: off [fixed]
hsr-tag-rm-offload: off [fixed]
hsr-fwd-offload: off [fixed]
hsr-dup-offload: off [fixed]


```raw
root@pve-02:~# ifconfig
eno1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 64:00:6a:51:d4:3d  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 20  memory 0xf7c00000-f7c20000

fwbr100i0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 96:bb:3a:75:a8:da  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

fwln100i0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 96:bb:3a:75:a8:da  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

fwpr100p0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 3e:b3:5b:1e:77:32  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tap100i0: flags=4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
        ether a6:2c:c3:33:51:1a  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vmbr0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.11  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::6600:6aff:fe51:d43d  prefixlen 64  scopeid 0x20<link>
        ether 64:00:6a:51:d4:3d  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


````
