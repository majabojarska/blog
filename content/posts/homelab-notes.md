+++
title = "Homelab documentation"
date = 2025-11-02
updated = 2026-02-11

[taxonomies]
tags = ["homelab", "notes", "reference", "infrastructure"]
+++

{{ image(src="img/homelab-notes/rack.webp") }}

This is a living document.

- Serves as a reference for my homelab.
- Helps me grow my technical documentation skills.

## Hosts

### Physical

- `pve-01.home.majabojarska.dev` — Lenovo Tiny M920q
  - Role: Main hypervisor
  - CPU: i5-8500T (6 x 2.1GHz)
  - RAM: 64GB DDR4 SODIMM.
  - Storage:
    - OS, disk images: 2TB M.2 NVMe
    - PCIe passthrough to virtual guests: 3 x 1TB 2.5" SATA SSD
- `pve-02.home.majabojarska.dev` — Dell Optiplex 7020
  - Role: Experimental hypervisor, spinner array host
  - CPU: i5-4590 (4 x 3.3GHz)
  - RAM: 24GB DDR3 DIMM
  - Storage:
    - OS, disk images: 120GB 2.5" SATA SSD
    - General purpose storage, VM passthrough:
      - (to be migrated) 2 x 2TB 3.5" SATA HDD
      - 1 x 640GB 3.5" SATA HDD
- `sp6cat-01.hswro.majabojarska.dev` — Lenovo Tiny M720q
  - Role: Off-site (colo) hypervisor.
  - CPU: i3-6100T (3 x 3.2GHz)
  - RAM: 8GB DDR4 SODIMM
  - Storage:
    - OS, disk images: 128GB NVMe SSD
    - 240GB 2.5" SATA SSD
    - (planned) 2x2TB 3.5" HDD in a ZFS mirror configuration.

### Virtual

- `opnsense.home.majabojarska.dev`
  - Role: home router
  - Hypervisor: `pve-01.home.majabojarska.dev`
- `kube-01.home.majabojarska.dev`
  - Role: single-node Kubernetes (K3s) cluster, bulk of self-hosted services.
  - Hypervisor: `pve-01.home.majabojarska.dev`
- `hass.home.majabojarska.dev`
  - Role: [Home Assistant OS](https://www.home-assistant.io/installation/alternative/)
  - Hypervisor: `pve-01.home.majabojarska.dev`
- `nas.home.majabojarska.dev`
  - Role: NAS
  - Hypervisor: `pve-02.home.majabojarska.dev`
- `sp6cat-vm-01.hswro.majabojarska.dev`
  - Role: multi-purpose, runs some services, hosts the blog.
  - Hypervisor: `sp6cat-01.hswro.majabojarska.dev`

## Networking

### Devices

- Netgear GS308E
  - Handles port-based, VLAN-aware switching ([802.1Q](https://en.wikipedia.org/wiki/IEEE_802.1Q)).
  - Facilitates running a router over a single ethernet interface in a secure fashion, via tagged VLANs.

- UniFi U6+
  - Converted to OpenWRT
  - Dumb, VLAN-aware AP with multiple software-defined APs
  - 2.4GHz, 5GHz
  - Uplinked to the router through a single trunk with tagged VLANs.

- OPNsense, virtualized on `pve-01.home.majabojarska.dev`.

### VLANs

| ID           | Role          |
| ------------ | ------------- |
| 0 (untagged) | Homelab       |
| 10           | IoT network   |
| 20           | Guest network |

### Addressing

| Network | IPv4 range (CIDR) | Gateway        | Has DHCP? |
| ------- | ----------------- | -------------- | --------- |
| Homelab | `192.168.1.0/24`  | `192.168.1.1`  | Yes       |
| IoT     | `192.168.10.0/24` | `192.168.10.1` | Yes       |
| Guest   | `192.168.20.0/24` | `192.168.20.1` | Yes       |

### DNS

- `majabojarska.dev` is the root domain for all my infrastructure needs.
- `home.majabojarska.dev` always points to `192.168.1.1` (intranet), which serves as the recursive resolver for any matching subdomains (wildcard).
- Tailscale is set up to use `192.168.1.1` as the resolver (one of). Meaning, remote VPN session resolve homelab domains just fine.
- `192.168.1.1` resolves outside domains via [DoH](https://en.wikipedia.org/wiki/DNS_over_HTTPS), with multiple upstream resolvers configured for redundancy.
- `home.majabojarska.dev` enforces DNS blocklist policies for ads, spam, and digital trash that I do not wish to resolve successfully.

### VPN

The OPNsense router handles all VPN routing, so that client devices can run light at home.

- A [Tailscale](https://tailscale.com/) client is configured as a [subnet router](https://tailscale.com/kb/1019/subnets) for the Tailnet.
- A [WireGuard](https://www.wireguard.com/) client provides peering to `hswro.org` infra.

### NTP

`home.majabojarska.dev` runs the [Chrony](https://chrony-project.org/) NTP server at the standard port `123`.

## Storage

:construction:

This section will describe the different storage pools/devices on different hosts, and their purposes.

## Backups

- Personal dev machines
  - Method: [Vorta (Borg Backup)](https://vorta.borgbase.com/) to a dedicated ZFS location on `nas.home.majabojarska.dev`.
  - Schedule: weekly
  - Trigger: manual, mostly due to `nas.home.majabojarska.dev` being powered off most of the time to limit energy consumption.
- Kubernetes PVs, ETCD snapshots:
  - Method: [Borgmatic](https://torsion.org/borgmatic/)
  - Schedule: nightly
  - Trigger: midnight cron
  - Notes:
    - As a pre-backup script, Borgmatic triggers an ETCD snapshot (to filesystem), and then cordons, drains, and stops the K3s systemd unit.
    - Backing up PVs and ETCD snapshots together ensures that upon disaster recovery, the "state of the world" is congruent between the cluster's state, and the applications' state.
- OPNsense configuration is version tracked in a self-hosted Git instance.
  - Method: [Git plugin](https://docs.opnsense.org/manual/git-backup.html)
  - Schedule: N/A
  - Trigger: any configuration change

## Encryption

### Secret management

#### Ansible

Ansible secrets are encrypted via [ansible-vault](ansible-vault decrypt group_vars/all/secrets.yaml).

```sh
# Decrypt
ansible-vault decrypt group_vars/all/secrets.yaml

# Encrypt
ansible-vault encrypt group_vars/all/secrets.yaml
```

The encryption key is not tracked by VCS, but it's kept in the homelab's password manager.

When cloning the repo on a new machine, place the key at `<repo_root>/.vault_pass` (defined via `ansible.cfg`).

#### Nix

- Secrets for NixOS hosts are encrypted at rest via [agenix](https://github.com/ryantm/agenix).
  - Effectively, the encryption is based on SSH key pairs.
- During deployment, they're shipped encrypted, and decrypted on the target host, with its own private key.
  - The target system is enrolled in the encryption scheme via its own, [autogenerated SSH key](https://nixos.wiki/wiki/Agenix#:~:text=%2Fetc%2Fssh%2Fssh%5Fhost%5Frsa%5Fkey) (in `/etc/ssh`).
- For each host: both the developer's (mine), and the target host's public keys are enrolled in the encryption scheme. In consequence, any of the corresponding private keys can be used to decrypt the secret, in order to update its contents.

The implementation is based on the [NixOS Agenix documentation](https://nixos.wiki/wiki/Agenix).

To edit an age secret or create a new one:

```sh
# From dir containing 'secrets.nix' and the age secrets.
# Alternatively, specify the path to the 'secrets.nix' file via the RULES env var.
nix run github:ryantm/agenix -- -e foo-token.age
```

To rekey an existing age secret:

```sh
# From dir containing 'secrets.nix'
nix run github:ryantm/agenix -- -r my-secret.age
```

#### Kubernetes

Secrets are encrypted through [SOPS](https://github.com/getsops/sops) backed by [age](https://github.com/FiloSottile/age), deployed via [FluxCD](https://fluxcd.io/flux/guides/mozilla-sops/#encrypting-secrets-using-age).

Most notably:

- The SOPS age private key is deployed at `flux-system/sops-keys`. It is also backed up via the lab's Bitwarden vault.
- The cluster's FluxCD config directory contains a `.sops.yaml` file, defining the file names and YAML keys allowlisted for encryption. It also contains the age public key – this key must match the deployed private key (they constitute a key pair).
- The encryption scheme is based on the following resources:
  - [FluxCD – Manage Kubernetes secrets with SOPS – Encrypting secrets using age](https://fluxcd.io/flux/guides/mozilla-sops/#encrypting-secrets-using-age)
  - [SOPS – 2.14 Using .sops.yaml conf to select KMS, PGP and age for new files](https://github.com/getsops/sops?tab=readme-ov-file#using-sops-yaml-conf-to-select-kms-pgp-and-age-for-new-files)
  - [FluxCD – Kustomization – Decryption](https://v2-0.docs.fluxcd.io/flux/components/kustomize/kustomization/)

Handy `~/.zshrc` snippet to aid with secret handling:

```sh
export SOPS_AGE_KEY_FILE="${HOME}/.sops/age.agekey"
alias sops-age-encrypt="sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE | grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place"
alias sops-age-decrypt="sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE | grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place"
```

### Disk Encryption

#### Benchmarks

Cipher and KDF performance is mostly relevant for disk encryption. Out of curiosity, I've benchmarked my hypervisors to see whether full-disk encryption would bottleneck storage throughput.

Nowadays (2026), most Linux distributions default to the `aes-xts-plain64` cipher with a 512 bits keysize, when enabling full-disk encryption via [LUKS](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/security_hardening/encrypting-block-devices-using-luks_security-hardening).
Therefore, the most relevant row in `cryptsetup benchmark` is the one with `aes-xts`;`512b`.

#### pve-01

```sh
root@pve-01:~# cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1      1562706 iterations per second for 256-bit key
PBKDF2-sha256    1913459 iterations per second for 256-bit key
PBKDF2-sha512    1405597 iterations per second for 256-bit key
PBKDF2-ripemd160  773286 iterations per second for 256-bit key
PBKDF2-whirlpool  557160 iterations per second for 256-bit key
argon2i       4 iterations, 1048576 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id      4 iterations, 1048576 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b       855.2 MiB/s      2380.0 MiB/s
    serpent-cbc        128b        74.6 MiB/s       590.7 MiB/s
    twofish-cbc        128b       171.7 MiB/s       312.7 MiB/s
        aes-cbc        256b       688.4 MiB/s      1933.1 MiB/s
    serpent-cbc        256b        80.4 MiB/s       586.6 MiB/s
    twofish-cbc        256b       185.3 MiB/s       318.7 MiB/s
        aes-xts        256b      2373.3 MiB/s      2380.8 MiB/s
    serpent-xts        256b       510.5 MiB/s       525.8 MiB/s
    twofish-xts        256b       290.6 MiB/s       300.8 MiB/s
        aes-xts        512b      1996.1 MiB/s      2006.5 MiB/s
    serpent-xts        512b       513.3 MiB/s       527.4 MiB/s
    twofish-xts        512b       295.6 MiB/s       296.0 MiB/s
```

#### pve-02

> Yet to come

#### sp6cat-01

```sh
sp6cat-01# cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1      1579180 iterations per second for 256-bit key
PBKDF2-sha256    1931079 iterations per second for 256-bit key
PBKDF2-sha512    1401839 iterations per second for 256-bit key
PBKDF2-ripemd160  781353 iterations per second for 256-bit key
PBKDF2-whirlpool  557753 iterations per second for 256-bit key
argon2i       4 iterations, 958355 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id      4 iterations, 964484 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b       871.5 MiB/s      2317.2 MiB/s
    serpent-cbc        128b        78.3 MiB/s       589.9 MiB/s
    twofish-cbc        128b       179.2 MiB/s       317.6 MiB/s
        aes-cbc        256b       687.5 MiB/s      1946.7 MiB/s
    serpent-cbc        256b        80.6 MiB/s       582.2 MiB/s
    twofish-cbc        256b       185.0 MiB/s       317.8 MiB/s
        aes-xts        256b      2255.7 MiB/s      2320.7 MiB/s
    serpent-xts        256b       509.9 MiB/s       519.2 MiB/s
    twofish-xts        256b       293.6 MiB/s       297.4 MiB/s
        aes-xts        512b      1944.7 MiB/s      1938.5 MiB/s
    serpent-xts        512b       515.6 MiB/s       519.5 MiB/s
    twofish-xts        512b       295.7 MiB/s       297.2 MiB/s

```

## Future plans & ongoing work

### Services

- Redeploy off-site hypervisors with full-disk encryption ([guide](https://forum.proxmox.com/threads/adding-full-disk-encryption-to-proxmox.137051/)).
- Deploy [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI) and integrate it with Jellyfin
- Setup [Authentik](https://goauthentik.io/) and SSO auth in services.
- O11y and alerting: [Grafana](https://github.com/renovatebot/renovate), [Prometheus](https://github.com/prometheus/prometheus), [ntfy](https://github.com/renovatebot/renovate).
  - Just need to reinstate this and hook up ntfy.

### Networking

- Migrate to [Cilium](https://cilium.io/).
- Control traffic flow with [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/).

### Hardware

#### Colocation

- Installed some hardware in a community-maintained colo.
- Working on a custom power regulation circuit that will allow me to power both a Lenovo Tiny, and 3 SATA drives from a single Lenovo 135W slim-tip PSU.

#### Disk bays

Planning to migrate my 2.5"/3.5" disks to a PCIe SATA controller. I'll use the following designs for rack-mounting the disks:

- [10" 2x 3.5" HDD](https://makerworld.com/en/models/1400538-10-inch-rack-1u-2-x-3-5-inch-hdd-hot-swap#profileId-2243810)
- [10" 4x 2.5" HDD/SSD](https://makerworld.com/en/models/1648104-10-inch-rack-1u-4x-2-5-inch-hdd-ssd-hot-swap#profileId-1742141)
