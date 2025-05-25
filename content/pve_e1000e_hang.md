+++
title = "Solving Intel e1000e NIC hangs on Proxmox VE 8.4-1"
date = 2025-05-25

[taxonomies]
tags = ["proxmox", "networking", "linux"]
+++

<!-- more -->

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

```sh
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
```
