#!/bin/sh
# Renders the SVG icons in icons/ into the strips the application loads.
#
# The icons are SVG because that is the only form that survives a high-DPI
# display: the tree images were a single 16-pixel strip, so on a 200% display
# they either sat at 16 pixels beside scaled text or were blown up to 32 and
# looked it. A strip per resolution, rendered from the same vector source,
# gives the LCL something honest to pick from.
#
# The output is checked in, so building Marathon needs neither this script nor
# ImageMagick. Run it after changing an icon.
#
#   tools/build_icons.sh
#
# Olive (#808000) is the transparent key: the loader passes the bitmap's own
# TransparentColor, which is the corner pixel, and every existing strip in this
# resource directory uses olive for it.

set -e
cd "$(dirname "$0")/.."

ICONS=$(ls icons/*.svg | sort)
OUT=src/Resources/Marathon
KEY='#808000'

for SIZE in 16 24 32; do
  TMP=$(mktemp -d)
  N=0
  for SVG in $ICONS; do
    convert -background none "$SVG" -resize ${SIZE}x${SIZE} \
      -gravity center -extent ${SIZE}x${SIZE} "$TMP/$(printf '%03d' $N).png"
    N=$((N + 1))
  done
  # One row, then flattened onto the key colour and written as the 24-bit BMP
  # the resource compiler takes.
  if [ "$SIZE" = "16" ]; then
    TARGET="$OUT/TreeImagesStrip.bmp"
  else
    TARGET="$OUT/TreeImagesStrip_$SIZE.bmp"
  fi
  # +repage after +append: the appended image keeps the page geometry of the
  # first tile, and -flatten works to the page, so without it every strip came
  # out one icon wide.
  convert "$TMP"/*.png +append +repage -background "$KEY" -flatten \
    -type truecolor BMP3:"$TARGET"
  echo "$TARGET  ($N icons at ${SIZE}x${SIZE})"
  rm -rf "$TMP"
done

# The strips reach the program through a compiled resource, not as files, so
# regenerate that too. Note that the .rc named ToolBarStrip.bmp while the file
# on disk is ToolbarStrip.bmp: the resource had always been compiled on
# Windows, where case does not matter, which is why this step could not be run
# here until the name was corrected.
( cd src/Resources/Marathon && fpcres Toolmenus.rc -o Toolmenus.RES -of res )
mv src/Resources/Marathon/Toolmenus.RES src/Source/Toolmenus.RES
echo "src/Source/Toolmenus.RES  (resource rebuilt)"
