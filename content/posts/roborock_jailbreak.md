+++
title = "Jailbreaking a Roborock Q7 Max robot vacuum"
date = 2025-06-26
updated = 2025-06-30

[taxonomies]
tags = ["vacuum", "jailbreak", "valetudo"]
+++

<!-- more -->

{{ image(src="img/roborock_jailbreak/title.webp", alt="Robot vacuum in the process of being rooted") }}

## The "Why?"

Robot vacuums are neat! Mine helps a lot with cat hair and managing allergies throughout the year. Having said that, these devices aren't exactly privacy respecting out of the box. From the looks of it, this is yet another market full of cloud connected designs, that doesn't offer a cloud free mode of operation.

Since there's no cloud free alternatives at the moment, the next best option is to choose a hackable device and perform post-market modifications. Granted, a robot vacuum isn't a must-have appliance in a household, like a washing machine is (to me). Not purchasing one in the first place is a perfectly valid option. However, it makes my life that much easier, so I opted to have one, on some conditions regarding data privacy.

## The "How?"

### Disclaimer

This post is geared towards the exact unit I'm working on. Your results may vary, and following the same guides might lead to different results on a newer unit of the same make and model, potentially permanently bricking your device. It is known, that newer devices can have a different design (under the same name), making previously known hacks obsolete. Proceed at your own discretion.

### Resources

These have been immensely helpful:

- [iFixit mechanical teardown guide](https://www.ifixit.com/Teardown/Roborock+Q7+Max:+Teardown/177329);
- [This robotinfo.dev page](https://robotinfo.dev/detail_roborock.vacuum.a38_0.html) – basically a reverse engineering summary for this model circa 2022;
- [DustBuilder](https://builder.dontvacuum.me/_a38.html) – provides the device-specific toolkit for rooting via [FEL](https://linux-sunxi.org/FEL);
- [The Valetudo Roborock guide](https://valetudo.cloud/pages/installation/roborock.html) – This will guide your through the FEL rooting process.

### Notes

#### Mechanical

- There are many different screw types and lengths. Get around 8 small trays to keep track of them throughout the disassembly. If you're following the iFixit guide linked above, I recommend labeling the trays with step numbers (e.g. sticky notes);
- Generally force is not needed here. There are some snap joints that need lifting with a flathead scredriver or some better suited pry tool, but you shouldn't need to wrestle with this device.
- I think there are non-metal threads inside, so be gentle when assembling it back together.

#### Electrical

{{ image(src="img/roborock_jailbreak/board_bot_tpa17.webp", alt="Conformal coating on test point TPA17", position="center") }}

- As one might expect, screw joints on the PCB are connected to common ground, just like the pad next to `TP17` (both marked blue).
- Apart from `TPA17` (marked red), there's also a `TP17` (marked yellow) test point (marked yellow), don't confuse them.
- The board is coated with a [conformal coating](https://en.wikipedia.org/wiki/Conformal_coating), to protect it from moisture and liquid damage. You'll need to gently scrape it off to make contact with the test point. A pointy multimeter probe will do just fine.
- The battery needs to be connected for the logic to boot, turns out it's not powered through the host USB connection! I believe the latter is mostly (or only) for UART.

Here are some more pictures of the board to help you identify it:

{{ image(src="img/roborock_jailbreak/board_top_full.webp", alt="Top of the board, middle section", position="center") }}

{{ image(src="img/roborock_jailbreak/board_top_middle.webp", alt="Top of the board, middle section", position="center") }}

{{ image(src="img/roborock_jailbreak/board_top_middle_2.webp", alt="Top of the board, middle section", position="center") }}

{{ image(src="img/roborock_jailbreak/board_top_right.webp", alt="Top of the board, right-hand section", position="center") }}

{{ image(src="img/roborock_jailbreak/board_top_left.webp", alt="Top of the board, left-hand section", position="center") }}

#### Rooting issues

The `sunxi-tools` toolchain is needed to flash the NAND, however I haven't had luck establishing a stable connection on Arch Linux ([btw](https://knowyourmeme.com/memes/btw-i-use-arch)). `dmesg` logged the FEL-booted device being detected, but the `sunxi-fel` calls failed with no connection.

```sh
sudo dmesg -w

[ 3962.317070] usb 1-2: new full-speed USB device number 15 using xhci_hcd
[ 3962.442370] usb 1-2: New USB device found, idVendor=1f3a, idProduct=efe8, bcdDevice= 2.b3
[ 3962.442378] usb 1-2: New USB device strings: Mfr=0, Product=0, SerialNumber=0
```

```sh
lsusb | grep FEL
Bus 001 Device 015: ID 1f3a:efe8 Allwinner Technology sunxi SoC OTG connector in FEL/flashing mode
```

```sh
[maja@the-arch-box fel]# sudo ./run.sh
ERROR: Allwinner USB FEL device not found!
ERROR: Allwinner USB FEL device not found!
waiting for 3 seconds
ERROR: Allwinner USB FEL device not found!
#...
```

I guessed this might work better on some Debian-based distro, as external hardware generally does. Spun up an Ubuntu VM, passed one USB port through, installed the dependencies, booted in FEL mode, started the flashing process, and it just worked!

```sh
[  488.355876] usb 2-1: new high-speed USB device number 4 using xhci_hcd
[  488.505916] usb 2-1: New USB device found, idVendor=1f3a, idProduct=1001, bcdDevice= 2.33
[  488.505922] usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[  488.505923] usb 2-1: Product: Rockrobo ruby
[  488.505929] usb 2-1: Manufacturer: Rockrobo USB Developer
[  488.505930] usb 2-1: SerialNumber: 91382b88b9076c118000
```

```sh
maja@ubuntu-fel:~$ lsusb
Bus 003 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 002 Device 002: ID 1f3a:efe8 Onda (unverified) V972 tablet in flashing mode
```

```sh
maja@ubuntu-fel:~/roborock/fel$ sudo ./run.sh
waiting for 3 seconds
100% [================================================]   852 kB,  196.0 kB/s
100% [================================================]    66 kB,  194.6 kB/s
100% [================================================]     0 kB,   84.8 kB/s
100% [================================================]  3898 kB,  197.2 kB/s
```

The rest of the process is done wirelessly, through SSH. If the robot was previously connected to a network, you might need to reset that configuration by holding the left and right buttons ("spot cleaning" and "home") until you hear the resetting wifi prompt.

From here I just followed the Valetudo Roborock FEL rooting and install guide without any changes.

#### Post-install info

System info. Given that Linux 3.4 was released on May 20th 2012, it was obsolete long before this vacuum [became available](https://www.nextpit.com/news/roborock-q7-max-plus-midrange-vacuum-robot-comes-spring), yikes!

```sh
[root@rockrobo ~]# uname -a
Linux rockrobo 3.4.39 #1 SMP PREEMPT Fri Dec 23 12:20:10 CST 2022 armv7l GNU/Linux
```

State of the filesystem:

```sh
[root@rockrobo ~]# df -h
Filesystem                Size      Used Available Use% Mounted on
rootfs                   23.1M     23.1M         0 100% /
/dev/root                23.1M     23.1M         0 100% /
devtmpfs                 64.0K         0     64.0K   0% /dev
none                    122.6M     44.0K    122.6M   0% /run
tmpfs                    30.0M     88.0K     29.9M   0% /var
tmpfs                    64.0K         0     64.0K   0% /dev
tmpfs                    60.0M      1.7M     58.3M   3% /tmp
tmpfs                   100.0M      3.9M     96.1M   4% /run/shm
/dev/nandl              142.8M     18.2M    117.3M  13% /mnt/data
/dev/nandb             1003.0K     31.0K    921.0K   3% /mnt/default
/dev/nandk                3.9M      1.4M      2.3M  39% /mnt/reserve
/dev/nandh                1.0M      1.0M         0 100% /mnt/resources/audio_bit
/dev/nandi                2.0M      2.0M         0 100% /mnt/resources/audio_default
/dev/nandj                1.9M      1.9M         0 100% /mnt/resources/audio_custom
```

Approximately 120MB of free space left, could fit something fun in here!

RAM, approximately 90MB left after excluding cache:

```sh
[root@rockrobo ~]# free
             total       used       free     shared    buffers     cached
Mem:        251184     237732      13452          0      10568      66092
-/+ buffers/cache:     161072      90112
Swap:            0          0          0
```

Listening server sockets:

```sh
[root@rockrobo ~]# netstat  -plntu
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:54322         0.0.0.0:*               LISTEN      812/miio_client
tcp        0      0 127.0.0.1:54323         0.0.0.0:*               LISTEN      812/miio_client
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      390/dropbear
tcp        0      0 127.0.0.1:5037          0.0.0.0:*               LISTEN      388/adbd
tcp        0      0 127.0.0.1:8079          0.0.0.0:*               LISTEN      386/valetudo
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      386/valetudo
netstat: /proc/net/tcp6: No such file or directory
udp        0      0 0.0.0.0:5353            0.0.0.0:*                           386/valetudo
udp        0      0 0.0.0.0:50438           0.0.0.0:*                           386/valetudo
udp        0      0 0.0.0.0:54321           0.0.0.0:*                           812/miio_client
udp        0      0 0.0.0.0:39255           0.0.0.0:*                           386/valetudo
udp        0      0 0.0.0.0:1900            0.0.0.0:*                           386/valetudo
udp        0      0 127.0.0.1:8053          0.0.0.0:*                           386/valetudo
udp        0      0 0.0.0.0:40901           0.0.0.0:*                           386/valetudo
netstat: /proc/net/udp6: No such file or directory
```

Binaries:

```sh
[root@rockrobo ~]# ls /bin
ash            chown          dnsdomainname  getopt         kill           mknod          netstat        pwd            sleep          umount
bash           cp             echo           grep           ln             mktemp         nice           rm             su             uname
busybox        date           egrep          gunzip         lock           mount          pidof          rmdir          sync           vi
cat            dd             false          gzip           login          mv             ping           run-parts      tar            zcat
chgrp          df             fgrep          hexdump        ls             nano           ping6          sed            touch
chmod          dmesg          fsync          hostname       mkdir          netmsg         ps             sh             true
[root@rockrobo ~]# ls /usr/bin
[               bzcat           diff            head            less            nslookup        rr_boot_flags   tee             uniq            xz
[[              clear           dirname         hexdump         logrotate.sh    openssl         rr_try_mount    test            uptime          yes
adbd            cmp             dropbearkey     htop            lsof            passwd          scp             time            watchdoge.sh
awk             create_ap       du              iconv           md5sum          pgrep           seq             top             wc
base64          crontab         env             id              mkfifo          pkill           setsid          tr              wget
basename        curl            expr            ionice          nano            printf          sort            traceroute      which
bootring        cut             find            killall         nc              readlink        strings         traceroute6     wpa_passphrase
bunzip2         dbclient        free            ldd             nohup           reset           tail            uart_test       xargs
```

It's worth noting there's no package manager, which to be honest I wouldn't expect in a consumer-grade commercial device.

---

All in all, the process was fairly straightforward. Nevertheless, I wouldn't recommend it to beginners, both in regard to hardware, and the software side of things. I was surprised to see a 4-core ARM chip inside of a robot vacuum. It's basically a low-memory single board computer. If it had more RAM, I'd make it into a Kubernetes node, just for shits and giggles.

To conclude, here's some [neofetch](https://github.com/dylanaraps/neofetch) eye candy 😋:

{{ image(src="img/roborock_jailbreak/neofetch.webp", alt="Neofetch on the Roborock", position="center") }}
