+++
title = "Working with WebP on Gnome"
date = 2025-07-12
updated = 2025-07-12

[taxonomies]
tags = ["linux", "gnome", "meta"]
+++

<!-- more -->

Whenever I'm writing this blog, I convert all of my images to [WebP](https://en.wikipedia.org/wiki/WebP). [Gnome](https://www.gnome.org/) however, my desktop environment, happens to be lacking in terms of WebP support. Here's a couple tricks to reduce the friction on Gnome 48.

## Thumbnail generation

Gnome does not support WebP thumbnailing natively, but it does support creating custom thumbnailers. [Calico Cat's response on StackExchange](https://askubuntu.com/a/1223606) provides an comprehensive guide on how to do it for WebP.

However, if you're on Arch Linux (or derivative), simply install the [webp-pixbuf-loader](https://archlinux.org/packages/?name=webp-pixbuf-loader) package instead.

## Convert to WebP from Nautilus

Nautilus file dialogs can be [easily extended with custom scripts](https://help.ubuntu.com/community/NautilusScriptsHowto). Here's a script that will convert all of the selected images to WebP:

```sh
#!/usr/bin/env bash

# Located at ~/.local/share/nautilus/scripts/convert-to-webp.sh
# Requires libwebp (provides cwebp)

while IFS= read -r PATH_INPUT; do
    PATH_DIR_PARENT="$(dirname "${PATH_INPUT}")"
    NAME_NO_EXT=$(basename "$PATH_INPUT" | cut -d. -f1)
    PATH_OUTPUT="${PATH_DIR_PARENT}/${NAME_NO_EXT}.webp"

    cwebp "${PATH_INPUT}" -o "${PATH_OUTPUT}"
done <<<"${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS}"
```

Note that this does not recurse into directories.

In case you prefer ImageMagick:

```diff
9c9
<     cwebp "${PATH_INPUT}" -o "${PATH_OUTPUT}"
---
>     convert "${PATH_INPUT}" "${PATH_OUTPUT}"
```

Now you'll get this dialog under _right-click_ → _Scripts_:

{{ image(src="img/webp-on-gnome/dialog.webp", alt="New WebP conversion dialog in Nautilus") }}
