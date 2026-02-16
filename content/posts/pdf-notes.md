+++
title = "Notes on working with PDFs on Linux"
date = 2025-12-27
updated = 2026-02-16

[taxonomies]
tags = ["pdf", "notes"]
+++

<!-- more -->

This is a collection of tips & tricks for working with PDF files in the Linux command line.

## Compress images (lossy)

```sh
ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output-file.pdf input-file.pdf
```

Requires the `ghostscript` package.

`-dPDFSETTINGS` collectively sets the output parameters, where:

- `/screen` – 72 DPI
- `/ebook` – 150 DPI
- `/prepress` – 300 DPI, use this if unsure and then fine-tune.

Specific paremeters can be controlled individually if needed.
See [Ghostscript docs – Distiller Parameters](https://ghostscript.readthedocs.io/en/gs10.05.1/VectorDevices.html#distiller-parameters) for more details.

## Reverse page order

```sh
pdftk input.pdf cat end-1 output output.pdf
```

Requires the `pdftk` package.

Page numbers `1,2,3` become `3,2,1` (and vice versa).

## Page rotation

### All pages

```sh
pdftk input.pdf cat 1-endwest output output.pdf
```

Rotate all pages 90° counter-clockwise. Note that `end` and `west` are semantically two separate instructions. `end` finishes the previous `cat` instruction, whereas `west` instructs the document processor to rotate the pages.

### Specific pages

```sh
pdftk input.pdf cat 1-2 3east 4-end output output.pdf
```

Keep 1,2,4 as-is, rotate 3 90° clockwise.

## Encryption

### Decrypt a PDF

```sh
qpdf --password=YOURPASSWORD-HERE --decrypt input.pdf output.pdf
```
