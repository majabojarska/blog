+++
title = "You wouldn't download a guitar amplifier"
date = 2026-09-03

[taxonomies]
tags = ["guitar", "NAM", "FOSS"]

[extra]
repo_view = true
comment = true
+++

[Amplifier modeling](https://en.wikipedia.org/wiki/Amplifier_modeling) has been around for decades. Modelers, i.e. the devices that facilitate the modeling, aim to digitally emulate the sound characteristics of an analog amplifier (traditionally consisting of vacuum tubes and/or transistors). They process the guitar's raw sound in real time, producing the output with less than a millisecond of latency, making them perfectly suitable for live settings. The result is then typically played back through the venue's own sound system.

Modelers are a reliable way to get a reproducible tone, wherever you go. They're also reasonably sized and lightweight, compared to a full rig. What's the catch? The good sounding ones are also _expensive_. It's unsurprising, given that every manufacturer had to develop their own emulation technology. A large part of the price was driven by the cost of research, software development, and testing. It's a reasonable purchase if you're a working musician, but I'm what you'd call a "bedroom guitarist". I play mostly at home in a small space, for my own enjoyment, which is why for the longest time I couldn't justify such a purchase, even though the tones can be face-melting (in a good way). I mean, check it yourself, go listen to a Kemper or Axe-Fx, and then look up their prices :grin:. 

In February of 2021, Steve Atkinson released [version 0.1 of the Neural Amp Modeler (NAM)](https://github.com/sdatkinson/neural-amp-modeler/releases?page=3#release-v0.1.0). The goal was simple, build an open-source toolchain for amplifier profiling and modeling. It was a niche project at the time, gradually gaining popularity ever since. Steve has a nice writeup about [The History of NAM](https://www.neuralampmodeler.com/post/the-history-of-nam) on his blog, check it out! 

Fast-forward to June 2026, NAM hit a major technological breakthrough with [the release of NAM A2](https://www.neuralampmodeler.com/post/a2-is-released). To put it bluntly, the capabilities are _insane_. NAM A2 surpasses flagship commercial modelers, both in [accuracy](https://www.tone3000.com/guides/nam-a2-the-complete-guide#amp-modeler-accuracy-test) and [blind listening tests](https://www.tone3000.com/guides/nam-a2-the-complete-guide#amp-modeler-blind-listening-test), all while requiring _less_ computation power. Remember how I mentioned the cost of R&D in modelers? Steve was kind and generous enough to share his research with the world, free of charge. 

Nowadays, there's a massive community involvement with the project. Collaborators took part in the blind listening tests for A2 candidates, helping perfect the formula. Previously, you could only run NAM as a plugin in your digital audio workstation. But because the toolchain is open, everybody can use it to develop new applications of the technology. People are building all kinds of NAM loaders, even for phones. Audio gear manufacturers are adopting NAM into their (commercial) products. Most notably, there's [TONE3000](https://www.tone3000.com/), a community-driven library of NAM profiles and IR responses, containing just about any kind of amplifier, cabinet, and space you could wish for. 

{{ image(src="static/img/you-wouldnt-download-an-amp/you-wouldnt-download-an-amp.webp", alt="Meme generated with https://youwouldntsteala.website/editor.html")}}

> Generated with [youwouldntsteala.website](https://youwouldntsteala.website/editor.html)

Shortly after NAM A2 was announced, I purchased a [Valeton GP-180](https://www.valeton.net/product/gp-180/) for ~730PLN (~170EUR). With the latest firmware upgrade, this unit is capable of natively loading NAM A2 lite models, making it a great value for the price. It's become my daily practice rig, I love it haha :grin:.

Anyway, try it out! If you'd like to support the project, you can:
- share the word with other fellow musicians,
- contribute to [NAM](https://www.neuralampmodeler.com/the-code) with patches, and to [TONE3000](https://www.tone3000.com/) with your captures,
- donate to the project [here](https://www.neuralampmodeler.com/donate).

---

In other news, as much as I like playing through the GP-180, the computer-side Valeton software is subpar, to put it lightly. I was hoping it'll run through [Wine](https://www.winehq.org/) on Linux, but NAM/IR uploads kept failing, presumably due to MIDI handling (all comms are MIDI SysEx). I'm currently reverse engineering the communication protocol in order to build a FOSS, platform-agnostic alternative leveraging [Web MIDI](https://developer.mozilla.org/en-US/docs/Web/API/Web_MIDI_API). Until that happens, I'm doing my upgrades and uploads through a Windows 10 VM, with USB passthrough 😭.

