# Security Policy

## Supported Versions

Only the latest release is actively supported.

## Reporting a Vulnerability

Please report security issues privately before opening a public issue.

If this repository is hosted under a GitHub account or organization, use GitHub private vulnerability reporting when available. Otherwise, open a minimal public issue asking for a private contact path without disclosing exploit details.

## Data Handling

Meeting Reminder reads calendar data from the local macOS Calendar database through EventKit.

The app does not:

- Send calendar data to a server
- Use Google Calendar API directly
- Include analytics or telemetry
- Store meeting content outside local app preferences

Popup settings and shown popup identifiers are stored locally with `UserDefaults`.
