#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="$ROOT_DIR/docs/assets"

swift run --package-path "$ROOT_DIR" ScreenshotRenderer "$ASSET_DIR"

echo "$ASSET_DIR"
