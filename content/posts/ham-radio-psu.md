+++
title = "Adapting a HPE server PSU for ham radio purposes"
date = 2025-08-05

[taxonomies]
tags = ["hack", "3d-printing", "electronics", "ham-radio"]
+++

<!-- more -->

- HSTNS-PL28-PSU
- Common Slot
- At the time of writing, an [Alinco DM-330MVT](https://www.dxengineering.com/parts/alo-dm-330mvt) costs $200 USD!
- thermal capacity
-

## Problem Statement

## Proof of Concept

{{ image(src="img/ham-radio-psu/psu-bare-backside.webp") }}
{{ image(src="img/ham-radio-psu/psu-bare-connector.webp") }}

{{ image(src="img/ham-radio-psu/hpe-common-slot-psu-pinout.webp") }}

1kΩ didn't work
Soldered 330Ω resistor

{{ image(src="img/ham-radio-psu/minimal-power-on-test.webp") }}

## Design

### Requirements

- 2x XT60 receptable, each capable of 10A sustained current.
- 2x Banana receptable pair (positive, negative), each pair capable of 5A sustained current.
- Standby power indicator.
- Power switch (standby/fully active).
- Digital voltmeter with a ±0.1V precision and accuracy.

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

{{ image(src="img/ham-radio-psu/psu-bare-top.webp") }}
{{ image(src="img/ham-radio-psu/psu-pcb-smd.webp") }}
