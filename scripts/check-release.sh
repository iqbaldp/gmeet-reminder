#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
INFO_PLIST="$ROOT_DIR/Resources/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
APP_PATH="$DIST_DIR/Meeting Reminder.app"
DMG_PATH="$DIST_DIR/MeetingReminder-$VERSION.dmg"
LATEST_DMG_PATH="$DIST_DIR/MeetingReminder.dmg"
CHECKSUMS_PATH="$DIST_DIR/SHA256SUMS.txt"

test -d "$APP_PATH"
test -f "$DMG_PATH"
test -f "$LATEST_DMG_PATH"
test -f "$APP_PATH/Contents/Resources/AppIcon.icns"

codesign --verify --deep --strict "$APP_PATH"
hdiutil verify "$DMG_PATH"

(
    cd "$DIST_DIR"
    shasum -a 256 "MeetingReminder-$VERSION.dmg" "MeetingReminder.dmg" > "$CHECKSUMS_PATH"
)

cat "$CHECKSUMS_PATH"
