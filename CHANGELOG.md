# Changelog

## 0.3.0

- Add a custom app icon.
- Add launch-at-login control from the menu bar.
- Package DMG releases with the app and an `Applications` shortcut.
- Emit versioned DMG filenames while keeping `MeetingReminder.dmg` as the latest alias.
- Keep popup reminders configurable, including the 10-second option and meeting-link open button.

## 0.2.0

- Add configurable popup reminders.
- Default popup offsets to 5 minutes and 1 minute before meeting start.
- Prevent duplicate popup windows for the same event and offset.

## 0.1.0

- Add minimal macOS menu bar reminder app.
- Read events from local macOS Calendar through EventKit.
- Send local notifications before meeting start.
