# Privacy

Meeting Reminder is designed as a local-first macOS utility.

## Calendar Access

The app reads events from the local macOS Calendar database through EventKit. If you use Google Calendar, your Google account must already be synced into macOS Calendar through Internet Accounts or the Calendar app.

Meeting Reminder does not connect directly to Google Calendar.

## Data That May Be Read Locally

To display reminders, the app may read:

- Event title
- Event start and end time
- Calendar name
- Event URL
- Event location
- Event notes, only to detect meeting links

## Data Storage

The app stores a small amount of local preference data using `UserDefaults`:

- Popup reminder offsets
- Popup identifiers that have already been shown

This prevents duplicate popup windows for the same event and offset.

## Network

Meeting Reminder does not intentionally make network requests.

Opening a meeting link uses the default browser. After that point, the destination service, such as Google Meet, Zoom, or Microsoft Teams, handles the page.

## Telemetry

The app does not include telemetry, analytics, crash reporting SDKs, or a backend service.

## Permissions

The app may request:

- Calendar access
- Notification access
- Launch-at-login registration

These are managed by macOS System Settings.
