+++
title = "Solving Intel e1000e NIC hangs on Proxmox VE 8.4-1"
date = 2025-05-25


[taxonomies]
tags = ["proxmox", "networking", "linux"]

+++

Recently I've been seeing my NAS' network interface go down unrecoverably (i.e. until a reboot). The first time I've observed this, I happened to be running some OS upgrades, so I brushed it off as a one-time, wonky interaction with the network interface. However, I've noticed it kept happening from time to time, so I started thinking about the common denominator of all of these cases. It only happened during high network throughput events, which saturated the gigabit link in a sustained fashion, like dumping backups or pulling several GBs of packages. On the other hand, the issue would never reproduce during lightweight networking tasks, like tweaking configs over SSH (even during long-lived sessions).

<!-- more -->

## The environment

{% mermaiddiagram() %}
architecture-beta
    group api(cloud)[API]

    service db(database)[Database] in api
    service disk1(disk)[Storage] in api
    service disk2(disk)[Storage] in api
    service server(mdi:ethernet)[Server] in api

    db:L -- R:server
    disk1:T -- B:server
    disk2:T -- B:db

{% end %}

The suspected NAS host is a NixOS VM running on top of [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview), which implies there's some virtual network complexity at play. To briefly explain the infrastructure, the VMs are networked to the hypervisor's physical interface via a [linux bridge interface](https://pve.proxmox.com/wiki/Network_Configuration). Logically, it's like a layer 2 switch, allowing to network multiple virtual NICs, via physical hypervisor interfaces, to the underlying lab network.

## Finding the root cause

Given the above, my first suspicion was naturally the virtual interface's configuration. I've seen these cause problems at scale in the past, when virtualizing embedded Linux devices for test automation purposes. I cannot stress how annoying these can be to troubleshoot, due to the loss of network connectivity. However, this specific situation was different from my past experience. Any attempt to contact the PVE hypervisor, let alone log into the console, resulted in connection failures. The host was not responding, hinting that it wasn't the VM's, but rather the hypervisor's NIC that was failing, causing the VM to go dark as a symptom of the broader issue.

By this point I could reproduce the issue reliably, by saturating the NAS interface with [iperf](https://iperf.fr/), with the other end of the link running on my router. In retrospect, saturating the hypervisor's interface might've been enough, but at the time I wanted to synthetically simulate the naturally occuring traffic flow through the NAS. Once the hypervisor's interface was trashed, I gracefully power cycled the machine, and started looking at kernel logs from the previous boot:

```sh
journalctl --dmesg --boot -1
```

Towards the end, I found a flurry of repeating errors relating to the e1000e network interface:

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
