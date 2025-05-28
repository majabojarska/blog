+++
title = "Solving Intel e1000e NIC hangs on Proxmox VE 8.4-1"
date = 2025-05-25


[taxonomies]
tags = ["proxmox", "networking", "linux"]

+++

Recently I've been seeing my NAS' network interface go down unrecoverably (i.e. until a reboot). The first time I've observed this, I happened to be running some OS upgrades, so I brushed it off as a one-time, wonky interaction with the network interface. However, I've noticed it kept happening from time to time, so I started wondering about the common denominator of all of these events. It would only happen during high network throughput events, which saturated the gigabit link in a sustained fashion, like dumping backups or pulling several GBs of packages. On the other hand, the issue would never reproduce during light loads (network-wise), like tweaking configs over SSH (even during long-lived sessions).

<!-- more -->

## The environment

{{ image(src="/img/pve_e1000e_hang/environment.svg", alt="Vacuum tube with powered on heater filaments",
         position="center", style="border-radius: 8px; width: 75%; padding: 16px;") }}

The suspected NAS host is a NixOS VM running on top of [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview), which implies there's some virtual network complexity at play. To briefly explain the infrastructure, the VMs are networked to the hypervisor's physical interface via a [linux bridge interface](https://pve.proxmox.com/wiki/Network_Configuration). Logically, it's like a layer 2 switch, allowing to connect multiple virtual NICs, via physical hypervisor interfaces, to the underlying lab network.

## Side note about virtualization

These NIC hangups quickly sent me down memory lane. Circa 2021, I was working on building out virtualization infrastructure for testing an embedded Linux device's software in its early stages. The crux of it was that it had several, multi-gigabit NICs, alongside some other, highly sensitive to timing physical interfaces. If I recall correctly, we did eventually have an early hardware prototype in the lab, but it wasn't fit for integrating into a CI pipeline, let alone doing so at scale. The challenge with virtualization here, was that the guest OS was a custom-built Yocto image, designed for the _real thing_.

Generally speaking, virtualizing a hardware-oriented device always calls for some trade-offs. Can't run nor test everything in a VM, since there's a boundary, beyond which you can't play pretend anymore (performance or inability to virtualize), or the pretending just stops being reasonably cost-effective (cheaper to use hardware, than build out custom tools enabling further virtualization). For example:

* Mocking DMI table info? Easy.
* Setting up disks for a software RAID? Easy.
* Passing through some USB devices? Easy.
* Getting the virtual NICs to behave exactly the same way as your SFP modules of choice, in a way that's compatible with the purpose-built software? [What color do you want your dragon?](https://knowyourmeme.com/photos/1052192-for-christmas-i-want-a-dragon). Software-side accommodations need to be considered in this situation, e.g. flags that inform the kernel it needs to boot with a slightly different configuration. Likewise, services might need to be mocked, or disabled altogether, due to the inability to satisfy certain hardware requirements. This implies limitationg to virtualized testing, but it's often still far better than nothing, when hardware units are scarce.

Now, back on topic!

## Finding the root cause

I happen to have another NixOS machine with an Intel NIC in my lab. It runs bare-metal with the same network configuration, without any hiccups whatsoever, so naturally I suspected the virtual NIC to be the culprit. However, this specific situation was different. Not only the VM, but the PVE hypervisor too, were becoming unreachable — simultaneously, like clockwork. Any attempt to reach the PVE hypervisor, let alone log into the console, resulted in connection failures. This behavior indicated it wasn't the VM's NIC, but rather the hypervisor's NIC that was failing, causing the VM to go dark as a symptom of the broader issue.

By this point, I could reproduce the failure reliably, by saturating the NAS interface with [iperf](https://iperf.fr/), with the other end of the link running on my router. In retrospect, saturating the hypervisor's interface might've been enough, but at the time I wanted to synthetically simulate the naturally occuring traffic flow _through_ the NAS. Once the hypervisor's interface was trashed, I gracefully power cycled the machine, and started looking at kernel logs from the previous boot:

```sh
journalctl --dmesg --boot -1
```

Looking towards the end, I found a flurry of repeating errors, relating to the `e1000e` network interface:

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

This was rooted in the host's specific hardware and kernel combination, freezing under stress (just like me)! As far as I'm concerned, the VM was irrelevant, it's the traffic that mattered. I quickly logged into the bare-metal NixOS machine to check the exact model of the ethernet controller on board:

```sh
[maja@m920q:~]$ lspci | grep -i eth
00:1f.6 Ethernet controller: Intel Corporation Ethernet Connection (7) I219-LM (rev 10)
```

I also checked a different (third) machine, running Proxmox, which happens to virtualize my OPNsense router. This one never failed me either, NIC-wise:

```sh
root@pve-03:~# lspci | grep -i eth
00:1f.6 Ethernet controller: Intel Corporation Ethernet Connection (2) I219-V
```

Both of these `I219` controllers belong to the [same product family and are roughly the same device](http://www.intel.com/content/www/us/en/embedded/products/networking/ethernet-connection-i219-family-product-brief.html), with `I219-LM` being geared towards server use, due to the added _vPro_ support. I frequently run both at 600+ mbps, and have yet to see them fail. The key conclusion here is that both `I219` controllers are different products from the failing `e1000e`, hence potentially resulting in a different interaction, under the same kernel/OS combination.

## Figuring out the `e1000e` issues

https://serverfault.com/questions/616485/e1000e-reset-adapter-unexpectedly-detected-hardware-unit-hang

https://serverfault.com/questions/193114/linux-e1000e-intel-networking-driver-problems-galore-where-do-i-start

https://forum.proxmox.com/threads/intel-nic-e1000e-hardware-unit-hang.106001/

https://www.kernel.org/doc/html/v5.12/networking/segmentation-offloads.html

https://linux.die.net/man/8/ethtool

https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/network_troubleshooting_and_performance_tuning/configuring-network-adapter-offload-settings

BEFORE

```sh
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
