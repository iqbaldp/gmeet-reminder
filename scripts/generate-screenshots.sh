#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="$ROOT_DIR/docs/assets"

for name in menu-bar dropdown popup dmg; do
    magick "$ASSET_DIR/$name.svg" "$ASSET_DIR/$name.png"
done

echo "$ASSET_DIR"
