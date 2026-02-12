+++
title = "Profiling K3s"
date = 2026-02-12

[taxonomies]
tags = ["kubernetes", "profiling"]
+++

```sh
curl --insecure https://kube-01.home.majabojarska.dev:6443/debug/pprof/profile\?seconds\=300
```

```sh
pprof -http=localhost:10101 profile-5min.pprof
```
