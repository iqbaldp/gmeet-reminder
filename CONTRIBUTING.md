# Contributing

Thanks for considering a contribution to Meeting Reminder.

## Development Setup

Requirements:

- macOS 14 or newer
- Xcode command line tools
- Swift Package Manager

Run the test suite:

```bash
swift test
```

Build the app bundle:

```bash
./scripts/build-app.sh
```

Build the DMG:

```bash
./scripts/build-dmg.sh
```

## Project Scope

Meeting Reminder intentionally reads the local macOS Calendar database through EventKit. It does not connect directly to Google Calendar and does not run a backend service.

Good contribution areas:

- Menu bar and popup reliability
- EventKit edge cases
- Meeting link extraction
- Release packaging
- Accessibility and copy improvements

Out of scope for now:

- App Store support
- Direct Google Calendar OAuth
- Telemetry or analytics
- Background server integrations

## Code Style

- Keep the app native and small.
- Prefer simple SwiftUI/AppKit code over broad abstractions.
- Add unit tests for scheduling, parsing, and formatting logic.
- Do not add inline comments. Use block-style documentation comments only when a comment is necessary.

## Pull Requests

Before opening a pull request:

```bash
swift test
./scripts/build-dmg.sh
```

Include a short summary, screenshots for UI changes, and any manual verification notes.
