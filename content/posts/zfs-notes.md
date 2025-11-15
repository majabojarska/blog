+++
title = "Notes on ZFS"
date = 2025-11-15

[taxonomies]
tags = ["homelab", "zfs", "filesystems", "storage"]
+++

<!-- more -->

My filesystem of choice for homelab purposes is ZFS. I tend to revisit certain configuration options every now and then, usually when working on my storage pools. This document aggregates it.

## Configuration

### Alignment shift

The alignment shift (`ashift`) communicates the _physical_ sector size of the underlying storage device (e.g. HDD, SSD), to ZFS. This value represents the number of bits — the exponent in a power of two. For older disks, this is usually 9 (512B), while for modern SSDs it's 12 (4K) or even 13 (8K).

Important considerations for choosing the `ashift` value:

- It is immutable and configurable only when adding a new device (disk) to a pool (vdev). This includes zpool creation, as `zpool create` requires providing a new device.
- ZFS tries to determine the proper `ashift` value by checking the disk's sector size. You should however, set it manually, as disks sometimes report a smaller sector size than they actually use internally (e.g. 512B, while actually using 4K). The purpose of mis-reporting is to maintain backward compatibility with older operating systems, as these might not support larger (more modern) sector sizes.
- It's better to overshoot, than to undershoot. Choosing an oversized `ashift` is generally fine, while an undersized will cause performance issues, due to a phenomenon called read/write amplification. Simply put, ZFS will have to perform many reads/writes to the disk, for every single ZFS block that's being written/read. This drastically decreases the performance of the pool.

You can check your disk's sector size via `fdisk`:

```sh
!# fdisk -l
Disk /dev/sdd: 953,87 GiB, 1024209543168 bytes, 2000409264 sectors
Disk model: <obfuscated>
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 33553920 bytes
Disklabel type: gpt
Disk identifier: <obfuscated>
```

Set `ashift` during pool creation as follows:

```sh
!# zpool create -o ashift=12 poolname mirror /dev/sdX /dev/sdY
```

Set `ashift` when adding devices:

```sh
!# zpool add -o ashift=12 poolname mirror /dev/sdA /dev/sdB
```

### Record size

This is a fairly complex topic, but the rule of thumb is:

| Purpose                           | `recordsize` |
| --------------------------------- | ------------ |
| Database                          | `64KiB`      |
| VM disk image                     | `64KiB`      |
| Multi-MiB media files             | `1M`         |
| Mixed-use (small and large files) | `128KiB`     |

If unset, ZFS will asume a default `recordsize` of `128KiB`.

### Access time

When `atime` is enabled (`on`), file access timestamps are written whenever a file is accessed. This increases the operational overhead and wears the disk out quicker. Unless you absolutely need to keep track of access times, disable this option:

```sh
!# zfs set atime=off poolname/datasetname
```

### Linux extended attributes

This section is TODO

TL;DR

```sh
!# zfs set xattr=sa poolname/datasetname
```

### Compression

Consider your dataset's compressibility and enable compression if you can reasonably expect space savings from enabling dataset compression.

What compresses well:

- plain text files,
- uncompressed image files like PNGs or GIFs,
- spreadsheets,
- compressed files appearing repeatedly.

What does **not** compress well:

- anything that's already compressed:
  - media (movies, photos, music),
  - ZIP/BZ2/LZMA/RAR archives.

Leaving compression enabled on a filesystem dedicated to storing already compressed files will mostly just chug electricity, while providing little to not benefit.

```sh
!# zfs set compression=lz4 poolname/datasetname
```

### Enabling snapshot directory visibility

ZFS supports auto-mounting a `.zfs` directory, at the root of each dataset. The `.zfs/snapshot` subdirectory will contain a directory for every single snapshot.

To enable this:

```sh
!# zpool set snapdir=visible poolname/datasetname
```

## Operations

### Rollback

List snapshots

```sh
!# zfs list -t snapshot
```

Rollback

```sh
!# zfs rollback storage/kubernetes@autosnap_2025-11-15_17:00:07_hourly
```

If there any newer snapshots present, you'll have to add the -r option, otherwise you'll hit the following error:

```sh
cannot rollback to 'storage/kubernetes@autosnap_2025-11-15_17:00:07_hourly': more recent snapshots or bookmarks exist
use '-r' to force deletion of the following snapshots and bookmarks:
storage/kubernetes@autosnap_2025-11-15_18:00:01_hourly
storage/kubernetes@autosnap_2025-11-15_20:00:55_hourly
```

Per `zfs help rollback`:

> -r Destroy any snapshots and bookmarks more recent than the one specified.
