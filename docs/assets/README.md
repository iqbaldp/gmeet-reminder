# Assets

Public-facing screenshots and generated screenshot sources live here.

Current files:

- `menu-bar.png`: menu bar item showing an upcoming meeting.
- `dropdown.png`: menu dropdown with upcoming meetings and popup settings.
- `popup.png`: custom meeting popup with `Open Meeting`.
- `dmg.png`: mounted DMG showing the app and `Applications` shortcut.

Avoid exposing private meeting titles, attendees, or meeting links in screenshots.

Regenerate PNG files from SVG sources:

```bash
./scripts/generate-screenshots.sh
```
