#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Meeting Reminder"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
STAGING_DIR="$DIST_DIR/dmg"
INFO_PLIST="$ROOT_DIR/Resources/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
VERSIONED_DMG_PATH="$DIST_DIR/MeetingReminder-$VERSION.dmg"
LATEST_DMG_PATH="$DIST_DIR/MeetingReminder.dmg"

"$ROOT_DIR/scripts/build-app.sh"

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$APP_DIR" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

rm -f "$VERSIONED_DMG_PATH" "$LATEST_DMG_PATH"
hdiutil create -volname "$APP_NAME $VERSION" -srcfolder "$STAGING_DIR" -ov -format UDZO "$VERSIONED_DMG_PATH"
cp "$VERSIONED_DMG_PATH" "$LATEST_DMG_PATH"

echo "$VERSIONED_DMG_PATH"
echo "$LATEST_DMG_PATH"
