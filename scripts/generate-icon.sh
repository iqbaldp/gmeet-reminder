#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICONSET_DIR="$ROOT_DIR/Resources/AppIcon.iconset"
SOURCE_SVG="$ROOT_DIR/Resources/AppIcon.svg"
OUTPUT_ICNS="$ROOT_DIR/Resources/AppIcon.icns"

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

magick "$SOURCE_SVG" -resize 16x16 "$ICONSET_DIR/icon_16x16.png"
magick "$SOURCE_SVG" -resize 32x32 "$ICONSET_DIR/icon_16x16@2x.png"
magick "$SOURCE_SVG" -resize 32x32 "$ICONSET_DIR/icon_32x32.png"
magick "$SOURCE_SVG" -resize 64x64 "$ICONSET_DIR/icon_32x32@2x.png"
magick "$SOURCE_SVG" -resize 128x128 "$ICONSET_DIR/icon_128x128.png"
magick "$SOURCE_SVG" -resize 256x256 "$ICONSET_DIR/icon_128x128@2x.png"
magick "$SOURCE_SVG" -resize 256x256 "$ICONSET_DIR/icon_256x256.png"
magick "$SOURCE_SVG" -resize 512x512 "$ICONSET_DIR/icon_256x256@2x.png"
magick "$SOURCE_SVG" -resize 512x512 "$ICONSET_DIR/icon_512x512.png"
magick "$SOURCE_SVG" -resize 1024x1024 "$ICONSET_DIR/icon_512x512@2x.png"

iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_ICNS"
rm -rf "$ICONSET_DIR"

echo "$OUTPUT_ICNS"
