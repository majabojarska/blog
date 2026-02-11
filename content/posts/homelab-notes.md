+++
title = "Notes on my homelab"
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
  - RAM: 32GB DDR4 SODIMM, hoping to expand to 64GB once prices fall a bit (one can hope).
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
      - 2 x 2TB 3.5" SATA HDD
      - 1 x 640GB 3.5" SATA HDD
- `pve-03.home.majabojarska.dev` — Lenovo Tiny M720q
  - Role: Secondary hypervisor, backup in case of `pve-01` failure.
  - CPU: i3-6100T (3 x 3.2GHz)
  - RAM: 8GB DDR4 SODIMM
  - Storage:
    - OS, disk images: 240GB 2.5" SATA SSD

### Virtual

- `opnsense.home.majabojarska.dev`
  - Role: homelab router
  - Hypervisor: `pve-01.home.majabojarska.dev`
- `kube-01.home.majabojarska.dev`
  - Role: Single-node Kubernetes (K3s) cluster, bulk of self-hosted services.
  - Hypervisor: `pve-01.home.majabojarska.dev`
- `hass.home.majabojarska.dev`
  - Role: [Home Assistant OS](https://www.home-assistant.io/installation/alternative/)
  - Hypervisor: `pve-01.home.majabojarska.dev`
- `nas.home.majabojarska.dev`
  - Role: NAS
  - Hypervisor: `pve-02.home.majabojarska.dev`
- `majabojarska.dev`
  - Role: general purpose VPS
  - Hypervisor: Linode Cloud

## Networking

### Devices

- Netgear GS308E
  - Handles port-based, VLAN-aware switching ([802.1Q](https://en.wikipedia.org/wiki/IEEE_802.1Q)).
  - Facilitates running a router over a single ethernet interface in a secure fashion, via tagged VLANs.

- Archer C6 v2
  - Dumb, VLAN-aware AP with multiple software-defined APs
  - 2.4GHz, 5GHz
  - Uplinked to the router a single trunk with tagged VLANs.

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

## Secret management

### Ansible

Ansible secrets are encrypted via [ansible-vault](ansible-vault decrypt group_vars/all/secrets.yaml).

```sh
# Decrypt
ansible-vault decrypt group_vars/all/secrets.yaml

# Encrypt
ansible-vault encrypt group_vars/all/secrets.yaml
```

The encryption key is not tracked by VCS, but it's kept in the homelab's password manager.

When cloning the repo on a new machine, place the key at `<repo_root>/.vault_pass` (defined via `ansible.cfg`).

### NixOS hosts

- Secrets for NixOS hosts are encrypted at rest via [agenix](https://github.com/ryantm/agenix).
  - Effectively, the encryption is based on SSH key pairs.
- During deployment, they're shipped encrypted, and decrypted on the target host, with its own private key.
  - The target system is enrolled in the encryption scheme via its own, [autogenerated SSH key](https://nixos.wiki/wiki/Agenix#:~:text=%2Fetc%2Fssh%2Fssh%5Fhost%5Frsa%5Fkey) (in `/etc/ssh`).
- For each host: both the developer's (mine), and the target host's public keys are enrolled in the encryption scheme. In consequence, any of the corresponding private keys can be used to decrypt the secret, in order to update its contents.

The implementation is based on the [NixOS Agenix documentation](https://nixos.wiki/wiki/Agenix).

To edit an age secret or create a new one:

```sh
# From dir containing 'secrets.nix'
# Alternatively, specify the path to the 'secrets.nix' file via the RULES env var.
nix run github:ryantm/agenix -- -e foo-token.age
```

### Kubernetes

- Kubernetes `Secret` objects are provisioned by the [External Secrets Operator](https://external-secrets.io/).
- `ExternalSecrets` define the `Secrets` to be provisioned (and managed).
  - Think of them as `Secret` recipes.
  - They only contain entry IDs and field names, referencing the backing secret store.
- Bitwarden is the secret store of choice, and it's defined via a [ClusterSecretStore](https://external-secrets.io/latest/api/clustersecretstore/) resource (cluster-wide).
- No plain-text secrets are stored in the `infra` Git repository, nor should they ever be.
- Bitwarden connectivity is provided by a Bitwarden CLI instance, running in-cluster, in HTTP server mode.
  - Docker image provided by [majabojarska/bitwarden-cli-docker](https://github.com/majabojarska/bitwarden-cli-docker).
  - Deployed using the ESO [Bitwarden Helm chart](https://github.com/majabojarska/bitwarden-cli-docker). Eventually to be replaced with [majabojarska/bitwarden-cli-helm](https://github.com/majabojarska/bitwarden-cli-helm), once that's ready. Also hoping to add this Helm chart as a recommendation to ESO docs, once the project matures (both implementation, and maintenance wise).
- Network connectivity between ESO components and the Bitwarden server is governed by a `NetworkPolicy`, and enforced by the [Flannel](https://github.com/flannel-io/flannel) CNI.
- Whenever new secrets are added, ESO might need a couple minutes to complete the secret reconciliation. Use longer timeouts to account for this when deploying new components requiring `Secrets`.
  - Planning to improve this with [Flux post-deployment jobs](https://fluxcd.io/flux/use-cases/running-jobs/).

#### SOPS

As of 2025-12-20, secrets are being migrated over to [SOPS](https://github.com/getsops/sops) backed by [age](https://github.com/FiloSottile/age), deployed via [FluxCD](https://fluxcd.io/flux/guides/mozilla-sops/#encrypting-secrets-using-age).

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

## Future plans & ongoing work

- Deploy [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI) and integrate it with Jellyfin
- Setup [Authentik](https://goauthentik.io/) and SSO auth in services.
- Setup [Renovate](https://github.com/renovatebot/renovate) for my infra, mainly for Helm chart autoupdate PRs.
  - This is already done, need to document the solution.
- O11y and alerting: [Grafana](https://github.com/renovatebot/renovate), [Prometheus](https://github.com/prometheus/prometheus), [ntfy](https://github.com/renovatebot/renovate).
  - Just need to reinstate this and hook up ntfy.
- Deploy [copyparty](https://github.com/9001/copyparty), remove [Nextcloud](https://github.com/nextcloud/server).
