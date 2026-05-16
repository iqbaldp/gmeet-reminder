# Release Checklist

## Before Release

- Confirm `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`.
- Update `CHANGELOG.md`.
- Update `docs/releases/<version>.md`.
- Run `swift test`.
- Run `./scripts/build-dmg.sh`.
- Run `./scripts/check-release.sh`.

## GitHub Release

- Create a tag matching the version, for example `v0.3.0`.
- Attach the versioned DMG from `dist`.
- Attach `SHA256SUMS.txt`.
- Paste release notes from `docs/releases/<version>.md`.

## Manual Smoke Test

- Open the DMG.
- Drag the app to `Applications`.
- Launch the app.
- Confirm the menu bar item appears.
- Confirm Calendar and Notification permissions work.
- Confirm popup settings are visible.
- Confirm launch-at-login toggle does not crash.
