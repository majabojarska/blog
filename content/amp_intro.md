+++
title = "Building a hybrid guitar amplifier from scratch"
date = 2025-04-03

[taxonomies]
tags = ["electronics", "guitar"]

[extra]
repo_view = true
comment = true
+++

<!-- more -->

{{ image(src="/img/amp/tube_heater_1.webp", alt="Vacuum tube with powered on heater filaments", position="center") }}

Designing and building a guitar amplifier from scratch has been on my mind for a fairly long time now.

> Building a guitar amplifier? Why not just buy one?

That's a perfectly valid question! A store-bought amp would likely have more features, more power, and cost way less time and money than this whole endeavour of mine. My goal however, is to _build_ one, not _have_ one (even though having one is a nice side effect of building one 😉). I want to learn about amplifier design practices, understand common pitfalls, design and improve my own solution, and most importantly, have fun throughout the process.

I initially hesitated to engage in this project, simply because I had no idea where to start.
Over the past decade I've built and modded guitar pedals, played around with [DAWs](https://en.wikipedia.org/wiki/Digital_audio_workstation), went through engineering studies, and worked on [A/V processing products](https://professional.dolby.com/product/dolby-cinema-imaging-products/ims3000/). All of these equipped me with a reasonably good understanding of engineering concepts relevant to signal processing, both analog and digital alike. However, I believe the missing piece for me, was gaining knowledge about _practical_ electronics design. Here are the main resources that helped me get started:

- [The Art of Electronics (AoE), by Paul Horowitz and Winfield Hill](https://en.wikipedia.org/wiki/The_Art_of_Electronics). Presents topics concisely, I (a hobbyist) find it to be quite accessible. It's also light on university-style spanning-four-blackboards maths. It's more focused on concepts, components and their practical applications, rather than the complete theory behind them. It does however, require some calculus, algebra, and physics, to fully grasp the examples.
- [NEETS module 6 - Electronic Emission, Tubes, and Power Supplies](https://archive.org/details/neetsmodules_202003/NEETS%20MOD%206%20NAVEDTRA%2014178A/page/n13/mode/2up). My 2015 Polish revision of AoE doesn't cover tubes, which although mostly obsolete, are still sought after in guitar amplfiers, due to their pleasant harmonic distortion.
- Dave Jones' videos on the [EEVblog YouTube channel](https://www.youtube.com/channel/UC2DjFE7Xf11URZqWBigcVOQ) (thanks Dave!).

## Starting out

{{ image(src="/img/amp/tube_heater_2.webp", alt="Vacuum tube with powered on heater filaments",
         position="center", style="border-radius: 1em; width: 75%;") }}

I've drafted some goals and constraints for my design:

- Driven by a 12V single supply.
- Vacuum tube preamplifier, since I happen to have one no-name [12AU7](https://en.wikipedia.org/wiki/12AU7) lying around (see pictures above). It's the perfect use case!
- Solid state power amplifier (PA) section. Rationale:
  - Power tubes require high voltages to operate (think 300-500V), which could deallocate me if I'm not careful enough, and I'm not taking that risk. They're also pricey and would require even more components to complete the PA section (power transformer). Additionally, they piss away a lot of energy in the form of heat (class A configuration being the worst).
  - Today's solid state PAs on the other hand, can operate on relatively low voltages (safe), are affordable, and far more energy efficient. [Class D amps can exceed 90% efficiency!](https://www.analog.com/en/resources/analog-dialogue/articles/class-d-audio-amplifiers.html) Moreover, they're also commonplace in many modern off-the-shelf amps ([example](https://www.positivegrid.com/pages/spark-series)).
- 1/4in headphone jack. Preferably, should mute the speaker output whenever headphones are plugged in.
- FX loop - after preamp, before PA. I'd like to inline some reverb at least.
- 1/4in, stereo, line-in level input. Will facilitate mixing in a metronome or some backing track directly from an external source. I thought about adding a cheap bluetooth audio module instead, but apparently nowadays they're all haunted by the [Chinese lady prompts](https://www.youtube.com/watch?v=aieHMRm7R7s). Somehow, this vibe doesn't dovetail with what I have in mind.
- Maybe a simple tone control section? We'll see.

---

I'm working on this project in the open:

- Developing the circuit design over at [majabojarska/bumble-tuby](https://github.com/majabojarska/bumble-tuby).
- Expect progress updates posted on this blog.

Till' next time!

{{ image(src="/img/amp/prototyping.webp", alt="Simplified pre-amp circuit on a breadboard", position="center") }}
