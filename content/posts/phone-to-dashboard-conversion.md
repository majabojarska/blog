+++
title = "Converting old smartphone into a server rack display"
date = 2025-07-22

[taxonomies]
tags = ["hack", "3d-printing", "homelab", "rack", "electronics", "monitoring"]
+++

<!-- more -->

## The idea

I really wanted to have some kind of display for my homelab. Since my server rack has a 10" form factor, I needed it to be compact, while still being functional.

- relatively small
- not cover server

{{ image(src="img/phone-to-dashboard-conversion/12864-display-modules.webp", alt="12864 display modules", position="center") }}


---

Topics:

- the idea
- battery removal
- phone first attempt, boot loop
- mock battery voltage, mobo modification
- testing, initial numbers
- enclosure design, print
- 0.2mm clearances
- 0.6mm nozzle for speed![alt text](image.png)

- assembly
  - total weight
- installation, velcro
- software side of things
- kiosk browser
  - automation, camera
- Grafana dashboard

## Prototype

Power:

- max 5W
- idle 0.6W
- active 1.3W

1n4007

Battery 67g
Phone no bat 141g

velcro

## What would I do differently now

- Wider side button access cutouts.
- Thinner wall in front of the USB-C port
-

{{ image(src="img/roborock_jailbreak/board_bot_tpa17.webp", alt="Conformal coating on test point TPA17", position="center") }}
