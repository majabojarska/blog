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

My favorite application of dot displays to date is the [Elektron Digitakt I (2017)](https://www.elektron.se/legacy), whose designers masterfully navigated the limitations of that canvas, to create a user interface that's both informative and mesmerizing alike. My friend happens to have one – I absolutely adore the animations.

{{ image(src="img/phone-to-dashboard-conversion/pexels-egorkomarov-17684555.webp", alt="Elektron Digitakt Dot display", position="center") }}

A commonly found dot display is the 12864 LCD, available in several sizes. They're quite popular in CNC machine control panels, for example in 3D printers. Their price is relatively low at around 20-40PLN, and they typically interface via SPI or I²C. They unfortunately don't come in a black&yellow variant, with the closest alternative being black&white.

{{ image(src="img/phone-to-dashboard-conversion/12864-display-modules.webp", alt="12864 display modules", position="center") }}

Initially, I thought the Digitakt simply has a black&white display with a yellow filter embedded into or overlaid onto it. But then, I found what I believe to be the exact part match, the 2.42" yellow OLED display (SSD1309):

{{ image(src="img/phone-to-dashboard-conversion/12864-oled-2-42-inch-yellow.webp", alt="12864 display modules", position="center") }}

### System Design

#### Variant A – On Host

{{ image(src="img/phone-to-dashboard-conversion/embedded-server-client-approach-a.svg", alt="System design - Variant A", position="center") }}

The host machine will run a Python service (`OLED display server`), which will fetch monitoring data, and draw it on the display.

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

#### Variant B – Split

{{ image(src="img/phone-to-dashboard-conversion/embedded-server-client-approach-b.svg", alt="System design - Variant B", position="center") }}

The host machine will run a lightweight Python service (`Metrics relay`). The service will fetch metrics from Prometheus and relay them to the I2C-capable device (`Display server`) via UART. The device draws on the multiple displays.

- Data transfer format between the metrics relay and the display server is irrelevant, as long as both parties support it. [Protocol Buffers](https://protobuf.dev/) could be adopted to facilitate unified data structure definition and serialization.

Pros:

- Multiple displays can be driven using a I2C-capable device. I2C multiplexers can be used to further increase the effective I2C address space.

Cons:

- Application code is scattered across two runtimes.
  - The development lifecycle will involve two separate deliverables, creating a risk factor of interface drift. In other words, the display server cannot render the user interface without receiving the necessary data in the first place. The metrics relay must satisfy the information requirements of the display server.
  - Requires extra glue code to link the devices.
  - Timing concerns arise, and what about communications breakdown (e.g. loose UART connection)?
  - Data integrity may be compromised.
- Overall this variant exhibits high complexity, with no clear benefit.

#### Variant C – Standalone

{{ image(src="img/phone-to-dashboard-conversion/embedded-server-client-approach-c.svg", alt="System design - Variant C", position="center") }}

This is an improvement of Variant B, cutting out the middle man.

- An ESP32 will run as a standalone, [Rust–based](https://github.com/esp-rs) embedded system.
- Network connection will be provided via WiFi.
- The system will fetch the metrics directly from Prometheus, process the data locally, and render the user interface out to the displays via I2C.

Pros:

- Leverages the pros of variant B, while eliminating its cons, it's a win-win scenario.
- While clear delineation between frontend (UI) and backend (metrics fetching) logic shall be maintained, this approach is still far simpler than variant B.
- Simple, unified architecture.

Cons:

- My cat is probably better at Rust than I am, but I can [git gud](https://knowyourmeme.com/memes/git-gud).
- Can't see any real downsides, this is a really good approach in my opinion.

## Second Approach – Repurposed Smartphone

The first approach has a significant caveat, in that it requires building (and maintaining) a fully custom display solution. I later remembered I had an old Android phone laying around. The phone was defective, but not in a way that would prevent me from using it as a dashboard. I've decided to pursue this idea instead.

### System Design

{{ image(src="img/phone-to-dashboard-conversion/phone-grafana-approach.svg", alt="System design - Second Approach", position="center") }}

The Android phone will run the Grafana in a web browser.

- The web browser of choice will be the [Fully Kiosk](https://www.fully-kiosk.com/) browser. It provides lifecycle automation capabilities unavailable in typical web browsers.
- Custom dashboards will be made to accomodate the aspect ratio and size of the phone's display.

Pros:

- Android provides nearly all of the necessary facilities out of the box – wireless networking, high-density display, app runtime, and touch input.
- Highly flexible environment, possible to repurpose in the future.

Cons:

- Hardware modifications will be required to adapt the phone to long-term grid power operation.
  - Battery cell must be removed to prevent [spicy pillows](https://www.reddit.com/r/spicypillows/) and spontaneous combustion.

### Hardware Modifications

With considerable effort and anxiety about puncturing, I've removed the Lithium-ion battery from the phone. This left me with an empty cavity inside the phone's body to install extra hardware.

{{ image(src="img/phone-to-dashboard-conversion/mainboard-raw.webp") }}

I've quickly learned that simply removing the battery wasn't sufficient for the phone operate just on USB power. It appears smartphones tend to check their battery upon boot (like a self-test). For this particular phone (Nokia G22), failing the check results in a bootloop.

Inspecting the power connector with a continuity tester proved that the battery connector has just two terminals, and therefore it cannot transmit any data (think serial number, manufacturing date, etc.). An obvious conlusion from this observation, is that the mainboard can only check the battery voltage level at any point in time. This in turn implies the mainboard can be cheated to "think" there's a working battery, by supplying a _battery-like_ voltage on the battery connector.

By _battery-like_, I mean any voltage within the nominal range of operation for a Lithium-ion battery. That happens to be somewhere between 3.0V and 4.2V. Given USB typically provides ~5.0V, a reference battery voltage could be created with any electronic component exhibiting a stable forward voltage drop of at least ~0.8V, and at most ~2V (assuming an ideal circuit).

I've confirmed this hypothesis by soldering two wires to conveniently placed battery test pads, and feeding 4.2V with a lab PSU, while simultaneously providing USB power. The phone booted just fine.

{{ image(src="img/phone-to-dashboard-conversion/mainboard-soldered-wires.webp") }}

Accounting for some voltage drop resulting from the USB cable's own resistance, I've opted for a 1N4007 signal diode, which provides an approx. 0.8-1.0V voltage drop at a current of 0.1-2A.

{{ image(src="img/phone-to-dashboard-conversion/1n4007-forward-voltage-vs-current.webp") }}

To be honest, I'm unsure how the on-board power management system uses the mocked battery. Hopefully, as long as it sees USB power – which is always, in this scenario – it will only use the mocked battery as a voltage reference, to determine whether it should begin a charging cycle. That way, power should be regulated more effectively, by the on-board switching regulators. Conversely, should the majority of current flow through the diode (mocked battery), a considerable amount of the energy would inadvertently be converted into heat. Certainly, the mocked battery cannot be "charged", in the sense of a reverse current flow, due to semiconducting nature of the diode.

At this point I did some measurements.

{{ image(src="img/phone-to-dashboard-conversion/psu-measure-prototype.webp") }}

| Mode of operation                                     | Power (approx.) |
| ----------------------------------------------------- | --------------- |
| Boot                                                  | 2.0-5.0W        |
| Idle, screen off                                      | 0.5W            |
| Grafana loading in Firefox, screen on, 30% brightness | 1.5W            |
| Grafana loaded in Firefox, screen on, 30% brightness  | 0.7W            |

### Enclosure

### Runtime Environment

### Takeaways

---

Topics:

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

{{ image(src="img/phone-to-dashboard-conversion/no-enclosure-testing.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/prototype.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/rear-camera-slot.webp") }}
{{ image(src="img/phone-to-dashboard-conversion/rear-wire.webp") }}
