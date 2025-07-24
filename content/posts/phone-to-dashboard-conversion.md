+++
title = "Converting an old smartphone into a server rack display"
date = 2025-07-28

[taxonomies]
tags = ["hack", "3d-printing", "homelab", "rack", "electronics", "monitoring"]
+++

<!-- more -->

## The Goal

For a long time now, I really wanted to have some kind of physical display for my homelab. One that would tell me how the infrastructure is doing, at a glance. Besides, I _love_ blinkenlights.

Given there's a myriad of solutions to choose from, I began with identifying my requirements:

- Physical:
  - Fits in a 10" rack.
  - Displayed information is legible at an arm's distance or less.
  - Does not cover the already installed servers.
  - Does not prevent access to the power strip and PSUs, or at least easily and reliably removable (e.g. magnets instead of screws).
- Electrical:
  - ≤ 1W power consumption on average.
  - Wall powered.
- Other:
  - Can convey basic information about the system's state, like CPU, memory, disk space.
  - Refresh rate of at least once every 5 seconds.
  - Preferably low cost – don't break the bank with a high-DPI, multicolor, e-ink display.

## First Approach – the Dot Display

My first idea was to browse through some cheap LCD/OLED display modules available online. One type of small displays I like particularly are dot displays. They tend to evoke a feeling of nostalgia in me, possibly for a world that I never even had a chance to experience. That's because I always imagined William Gibson's netrunners using retrofuturistic displays. You know, nixie tubes, 14-segments, dot matrices, CRTs, and finally large-pixel displays.

My favorite application of Dot displays to date is the [Elektron Digitakt I (2017)](https://www.elektron.se/legacy), whose designers masterfully navigated the limitations of that canvas, to create a user interface that's both informative and mesmerizing alike. My friend happens to have one – I absolutely adore the animations.

{{ image(src="img/phone-to-dashboard-conversion/pexels-egorkomarov-17684555.webp", alt="Elektron Digitakt Dot display", position="center") }}

A commonly found dot display is the 12864 LCD, available in several sizes. They're quite popular in CNC machine control panels, for example in 3D printers. Their price is relatively low at around 20-40PLN, and they typically interface via SPI or I²C. They unfortunately don't come in a black&yellow variant, with the closest alternative being black&white.

{{ image(src="img/phone-to-dashboard-conversion/12864-display-modules.webp", alt="12864 display modules", position="center") }}

Initially, I thought the Digitakt simply has a black&white display with a yellow filter embedded into or overlaid onto it. But then, I found what I believe to be the exact part match, the 2.42" yellow OLED display (SSD1309):

{{ image(src="img/phone-to-dashboard-conversion/12864-oled-2-42-inch-yellow.webp", alt="12864 display modules", position="center") }}

### System Design

#### Variant A

{{ image(src="img/phone-to-dashboard-conversion/embedded-server-client-approach-a.svg", alt="System design - Variant A", position="center") }}

The host machine will be running a Python service (`OLED display server`), that will fetch monitoring data, and draw it on the display.

- The host machine will interface with the display via a USB-I²C adapter.
- The USB-I²C adapter will be implemented by flashing a RP2040 board with I²C adapter firmware [[1](https://github.com/Nicolai-Electronics/rp2040-i2c-interface)]. Alternatively, a pre-made adapter can be purchased.
  - The I²C adapter will implement the [i2c-tiny-usb](https://github.com/harbaum/I2C-Tiny-USB) protocol, to facilitate integration with the [Linux USB project](http://www.linux-usb.org/).
- The service will utilize the [luma.oled](https://github.com/rm-hull/luma.oled) library to interact with the display(s).
- The service will fetch the required monitoring data through the network, from a Prometheus server.

Pros:

- Centralized implementation of the fetch/draw logic.
- Fast development cycle.
- Ease of debugging.
- Can run on any host, as long as there's network access to the target Prometheus instance.

Cons:

- Potential inability to drive multiple displays via one RP2040, even though the chip has two I²C buses.
- The device is not standalone, requires a host to run the Python service.

#### Variant B

Thin service fetches/sends prometheus data from/to i2c device via UART. The device draws on the multiple displays.

### Variant C

Standalone networked device pulls data from Prometheus and draws it on the display.
Rust, WiFi.

## Second Approach – Repurposed Smartphone

### System Design

### Hardware Modifications


Power:

- max 5W
- idle 0.6W
- active 1.3W

1n4007

Battery 67g
Phone no bat 141g

velcro
- battery removal
- phone first attempt, boot loop
- mock battery voltage, mobo modification
- testing, initial numbers

### Enclosure

### Runtime Environment

### Takeaways

---

Topics:

- the idea

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

## What would I do differently now

- Wider side button access cutouts.
- Thinner wall in front of the USB-C port
-

{{ image(src="img/phone-to-dashboard-conversion/backside-wire-run.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/diode-voltage-drop-measurement.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/first-boot-assembly.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/IMG_20250716_211059.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/installed-on-rack-door.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/internal-frame-printing.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/internal-frame.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/internal-wiring.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/mainboard-raw.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/mainboard-soldered-wires.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/no-enclosure-testing.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/prototype.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/psu-measure-prototype.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/rear-camera-slot.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/rear-wire.webp") }}
