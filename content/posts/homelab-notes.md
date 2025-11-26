+++
title = "Notes on my homelab"
date = 2025-11-02
updated = 2025-11-26

[taxonomies]
tags = ["homelab", "notes", "reference", "infrastructure"]
+++

This is a living document.

- Serves as a reference for my homelab.
- Helps me grow my technical documentation skills.

## Physical hosts

:construction:

## Networking

:construction:

## Storage

:construction:

## Backups

:construction:

- Borgmatic backs up kubernetes volumes off-site.

Ideas:

- Run a k3s snapshot as part of the pre-backup borgmatic hook. This will ensure every application state backup is paired with a matching K3s state.

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
- For each host: both the developer's (mine), and the target host's public keys are enrolled in the encryption scheme. In consequence, any of the corresponding private keys can be used to decrypt the secret, in order to update its contents.

To edit an age secret:

```sh
# From dir containing 'secrets.nix'
# Alternatively, specify the path to the 'secrets.nix' file via the RULES env var.
nix run github:ryantm/agenix -- -e tailscale-auth-key.age
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

## Future plans & ongoing work

- Deploy [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI) and integrate it with Jellyfin
- Setup [Authentik](https://goauthentik.io/) and SSO auth in services.
- Setup [Renovate](https://github.com/renovatebot/renovate) for my infra, mainly for Helm chart autoupdate PRs.
- O11y and alerting: [Grafana](https://github.com/renovatebot/renovate), [Prometheus](https://github.com/prometheus/prometheus), [ntfy](https://github.com/renovatebot/renovate).
- Rework ZFS SSD pool to be managed by PVE, instead of by lifted-n-shifted guest VM via disk passthrough.
- Deploy [copyparty](https://github.com/9001/copyparty), remove [Nextcloud](https://github.com/nextcloud/server).
