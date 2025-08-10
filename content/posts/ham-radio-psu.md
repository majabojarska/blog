+++
title = "Adapting a HPE server PSU for ham radio purposes"
date = 2025-08-12

[taxonomies]
tags = ["hack", "3d-printing", "electronics", "ham-radio"]
+++

<!-- more -->

## Problem Statement

Ham radios typically require a power supply of 13,8V at a relatively high current. Here are some examples, based on the respective user's manual recommendations:

| TRX model     | TX power | Minimal PSU current rating |
| ------------- | -------- | -------------------------- |
| Xiegu G90     | 20W      | 8A                         |
| Icom IC-2730A | 50W      | 13A                        |
| Yaesu FT-857D | 100W     | 22A                        |

An obvious way to power a radio would be to purchase a purpose-built, ham radio PSU. The thing is, these are pricey. At the time of writing, an _Alinco DM-30E_ would run me upwards of 590 PLN. I don't want to spend that kind of money when there's a 10x cheaper alternative, and that's used server PSUs. You can get them for cheap, at anywhere between 300W and 1000W of power. These come from decommisioned datacenter hardware, hence are rugged and widely available. It's also a tried and tested solution in ham radio circles.

After initial research, I found the HP Enterprise product line PSUs to be the most approachable, given their hackability and availability in my area. They're standardized in terms of the physical footprint and electrical interface ([HPE Common Slot](https://support.hpe.com/connect/s/product?language=en_US&kmpmoid=345072&tab=manuals)), even across multiple hardware generations.

## Proof of Concept

I got a _HSTNS-PL28_ 460W unit for just 45 PLN. Per the specification, it can output up to 38.3A, at 12V. That's plenty enough, even for a 100W radio (see table above).

{{ image(src="img/ham-radio-psu/psu-bare-top.webp") }}
{{ image(src="img/ham-radio-psu/psu-bare-backside.webp") }}
{{ image(src="img/ham-radio-psu/psu-bare-connector.webp") }}

The first step was to figure out how to power on the main 12V rail. In a bare-bones shape, when connected to 230V AC, the unit would power on only in the standby sense — fan spin, power LED blinking.

I found this HPE Common Slot PSU specification over at the [RCGroups forum](https://www.rcgroups.com/forums/showpost.php?p=36523697&postcount=3709):

{{ image(src="img/ham-radio-psu/hpe-common-slot-psu-pinout.webp") }}
{{ image(src="img/ham-radio-psu/hpe-common-slot-psu-led-signals.webp") }}

Per the above, pin 33 (`PSON#`) expects a PSU on/off control signal. I found mixed info on this topic, with the general consensus being that it needs to be pulled high. I tried with a 1kΩ resistor first, across pins 33 and 37 (`12VSB`). That wasn't enough to achieve power on, so I've tried with a 330Ω instead, which worked just fine.

{{ image(src="img/ham-radio-psu/minimal-power-on-test.webp") }}

I've let the PSU run unloaded for ~10min, throughout which the 12V rail exhibited a stable voltage of ~12.3V. I didn't perform a high-current (>10A) stress test, since I didn't have an appropriate load at my lab. Nevertheless, this proves the concept. Should the PSU fail at high currents, it will be a specific unit's problem, not a problem with the idea per se.

## Design

### Requirements

- Power switch (standby/fully on).
- Standby power indicator (on the front).
- 2x XT60 receptable, each capable of 10A sustained current.
- 2x Banana receptable pair (positive, negative), each pair capable of 5A sustained current.
- Digital voltmeter with a ±0.1V precision and accuracy.
- All of the above I/O interfaces shall be exposed on a single front panel.

### Electrical

{{ image(src="img/ham-radio-psu/voltmeter-module.webp") }}

### Mechanical

{{ image(src="img/ham-radio-psu/cad-isometric-corner-view.webp") }}
{{ image(src="img/ham-radio-psu/cad-perspective-back.webp") }}
{{ image(src="img/ham-radio-psu/cad-perspective-front.webp") }}

You can find the full Onshape CAD project [over here](https://cad.onshape.com/documents/186bdf1a0111d524a947b540/w/e2b5be03c8dc713116451386/e/d2109c2b51c15bd55eb2ff8c?renderMode=0&uiState=6891221ac752151697f70cb8).

## Assembly

{{ image(src="img/ham-radio-psu/enclosure-internal-wiring.webp") }}
{{ image(src="img/ham-radio-psu/enclosure-semi-assembled.webp") }}
{{ image(src="img/ham-radio-psu/enclosure-wiring-wide.webp") }}

{{ image(src="img/ham-radio-psu/soldering-top.webp") }}

## Testing

{{ image(src="img/ham-radio-psu/radio-test.webp") }}

## Possible Improvements

### 13,8V output voltage

{{ image(src="img/ham-radio-psu/psu-pcb-smd.webp") }}
