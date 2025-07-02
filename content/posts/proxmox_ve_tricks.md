+++
title = "Notes on Proxmox VE"
date = 2025-01-27
updated = 2025-06-02
[taxonomies]
tags = ["homelab", "proxmox"]
+++

<!-- more -->

Living collection of snippets, tips and tricks for [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview).

## Post-install

### Non-subscription software repositories

1. Disable the enterprise repository:

   ```sh
   mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.disabled
   ```

1. Disable the Ceph repository:

   ```sh
   mv /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.disabled
   ```

1. Enable the no-subscription repository ([source](https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_no_subscription_repo)):

   ```sh
   echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
   ```

1. Upgrade the node:

   ```sh
   apt update && apt upgrade -y
   ```

1. Remove the subscription notice in the web client. Credits go to [John McLaren](https://johnscs.com/remove-proxmox51-subscription-notice/):

   ```sh
   sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
   ```

## User management

### Manually delete a user

Delete user from `/etc/pve/user.cfg` and `/etc/pve/priv/shadow.cfg`.

## Networking

### Firewall

- Do not enable firewall before configuring it (Default input policy is to `DROP` everyting).
- Lower-level rules override higher-level rules. For example, datacenter rules are overridden by node rules, if firewall is enabled on the node.

## CLI

### Virtual Machines

`qm` - Qemu/KVM Virtual Machine Manager

`qm start <id>` - Start VM.

`qm shutdown <id>` - Gracefully shutdown VM.

`qm reset <id>` - Reset VM (kill and start immediately).

`qm stop <id>` - Kill VM immediately.

`qm set <id> --onboot 0` - Disable start on boot for VM.

`qm config <id>` - Get VM config.

### Containers

`pct` - Tool to manage Linux Containers (LXC) on Proxmox VE

`pct list` - List containers.

`pct config <id>` - Get container config.

`pct enter <id>` - Open shell session on container.
