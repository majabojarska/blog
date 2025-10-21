# majabojarska.dev

[![Build](https://github.com/majabojarska/majabojarska.dev/actions/workflows/status.yaml/badge.svg)](https://github.com/majabojarska/majabojarska.dev/actions/workflows/status.yaml?branch=main) [![Deploy](https://github.com/majabojarska/majabojarska.dev/actions/workflows/deploy.yaml/badge.svg)](https://github.com/majabojarska/majabojarska.dev/actions/workflows/deploy.yaml?branch=main)

The source code for my personal website.

This website is built on [Zola](https://www.getzola.org/), the static site generator.

---

## To-do topics

- Posts
  - k3s graceful shutdown
    - [Oranki net post](https://oranki.net/posts/2025-01-09-graceful-k3s-shutdown/)
  - homelab in general
  - kube backups
  - Preprocessing ING CSV for actual
  - Clock-safe reboot for openwrt
  - Workflow for adding required status checks in github
- Meta
  - Automate `updated` post param updating.
  - Factor out custom SCSS

---

On kube backups:

- Using [local-path-provisioner](https://github.com/rancher/local-path-provisioner) on a local ZFS array.
  - Yes, I know using host storage is not very _cloud native_ of me, but I'm not deploying and maintaining an object storage solution for a single-node, homelab cluster.
  - Ideal solution given my setup:
    1. Stop Kubernetes workloads.
    1. Take ZFS snapshot (this is almost immediate).
    1. Start Kubernetes workloads.
    1. Create backup archive from the snapshot (deduplicate, compress, upload).
  - Least-effort, realistic solution for now:
    1. Stop Kubernetes workloads.
    1. Create backup from live ZFS mount. This takes far longer than creating a spanshot
    1. Start Kubernetes workloads.
