# majabojarska.dev

[![Build](https://github.com/majabojarska/majabojarska.dev/actions/workflows/status.yaml/badge.svg)](https://github.com/majabojarska/majabojarska.dev/actions/workflows/status.yaml?branch=main) [![Deploy](https://github.com/majabojarska/majabojarska.dev/actions/workflows/deploy.yaml/badge.svg)](https://github.com/majabojarska/majabojarska.dev/actions/workflows/deploy.yaml?branch=main)

The source code for my personal website.

This website is built on [Zola](https://www.getzola.org/), the static site generator.

## Development

```sh
docker run --rm --name blog --network host -v $PWD:/blog ghcr.io/getzola/zola:v0.21.0 --root /blog serve
```

---

## To-do topics

- Posts
  - k3s graceful shutdown
    - A NixOS-specialized case of this [Oranki net post](https://oranki.net/posts/2025-01-09-graceful-k3s-shutdown/)
  - kube backups
  - Preprocessing ING CSV for actual
- Meta
  - Automate `updated` post param updating.
  - Factor out custom SCSS
