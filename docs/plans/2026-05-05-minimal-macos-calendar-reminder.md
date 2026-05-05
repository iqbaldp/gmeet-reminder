# Minimal macOS Calendar Reminder Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a minimal macOS menu bar app that reads locally synced Calendar events and reminds the user before meetings.

**Architecture:** Use a native Swift app packaged from SwiftPM output into a `.app` bundle. The app reads upcoming events through EventKit, renders a `MenuBarExtra`, and schedules local macOS notifications through UserNotifications.

**Tech Stack:** Swift 5.10+, SwiftUI, AppKit, EventKit, UserNotifications, Swift Package Manager, shell scripts for `.app` and `.dmg` packaging.

---

## Constraints

- Minimum target is `macOS 14`.
- No Google Calendar API in V1.
- No App Store support in V1.
- No custom popup window in V1.
- No launch-at-login in V1.
- No inline code comments; use JSDoc-style block comments only when comments are necessary.
- Calendar source is the local macOS Calendar database, so users must sync Google Calendar through macOS Calendar or Internet Accounts.
- GitHub DMG distribution is acceptable, but unsigned or unnotarized builds may trigger Gatekeeper warnings.

## Product Behavior

- Menu bar shows the next meeting title and relative time, for example `Dev Team x Su... in 10m`.
- If a meeting is currently active, menu bar shows `Dev Team x Su... now`.
- If there are no more meetings today, menu bar shows `No meetings`.
- Dropdown menu shows upcoming meetings for the current day.
- App sends local notifications at `10 minutes before`, `5 minutes before`, and `start time`.
- App refreshes events every `60 seconds`.
- App refreshes immediately when EventKit reports calendar changes.
- App refreshes before scheduling the next reminder cycle.

## Planned File Structure

```text
Package.swift
Sources/MeetingReminderApp/App/MeetingReminderApp.swift
Sources/MeetingReminderApp/App/AppDelegate.swift
Sources/MeetingReminderApp/Calendar/CalendarEvent.swift
Sources/MeetingReminderApp/Calendar/CalendarService.swift
Sources/MeetingReminderApp/MenuBar/MenuBarView.swift
Sources/MeetingReminderApp/MenuBar/MenuBarViewModel.swift
Sources/MeetingReminderApp/Notifications/NotificationService.swift
Sources/MeetingReminderApp/Scheduling/ReminderScheduler.swift
Sources/MeetingReminderApp/Support/DateFormatting.swift
Resources/Info.plist
Resources/MeetingReminder.entitlements
scripts/build-app.sh
scripts/build-dmg.sh
README.md
```

## Task 1: Create SwiftPM App Skeleton

**Files:**
- Create: `Package.swift`
- Create: `Sources/MeetingReminderApp/App/MeetingReminderApp.swift`
- Create: `Sources/MeetingReminderApp/App/AppDelegate.swift`
- Create: `Resources/Info.plist`
- Create: `Resources/MeetingReminder.entitlements`

**Step 1: Add package manifest**

Create a Swift executable package named `MeetingReminderApp` targeting macOS 14.

Expected requirements:
- Product type: executable.
- Target path: `Sources/MeetingReminderApp`.
- Link against native Apple frameworks through Swift imports, not package dependencies.

**Step 2: Add the app entry point**

Create a SwiftUI `@main` app with:
- `MenuBarExtra`
- no main window
- `NSApplicationDelegateAdaptor` for app lifecycle hooks

**Step 3: Add Info.plist**

Include these keys:
- `CFBundleIdentifier`: `com.iqbaldp.meeting-reminder`
- `CFBundleName`: `Meeting Reminder`
- `LSUIElement`: `true`
- `NSCalendarsFullAccessUsageDescription`: explain that the app reads calendar events to show meeting reminders.
- `NSUserNotificationUsageDescription` or notification-related usage text where applicable.

Apple's current EventKit requirement for macOS 14+ is full access via `NSCalendarsFullAccessUsageDescription` when reading calendar events.

**Step 4: Add entitlements**

Include calendar entitlement for sandbox-compatible local builds:
- `com.apple.security.app-sandbox`
- `com.apple.security.personal-information.calendars`

**Step 5: Build**

Run:

```bash
swift build
```

Expected: build succeeds and produces `.build/debug/MeetingReminderApp`.

## Task 2: Implement Calendar Event Model

**Files:**
- Create: `Sources/MeetingReminderApp/Calendar/CalendarEvent.swift`
- Create: `Sources/MeetingReminderApp/Support/DateFormatting.swift`

**Step 1: Define event model**

Create a small struct with:
- `id`
- `title`
- `startDate`
- `endDate`
- `calendarTitle`
- `isAllDay`
- `url`

**Step 2: Add display helpers**

Implement helpers for:
- trimmed title fallback to `Untitled Meeting`
- `isActive(now:)`
- `startsWithin(minutes:now:)`
- relative menu bar text
- dropdown time range text

**Step 3: Build**

Run:

```bash
swift build
```

Expected: build succeeds.

## Task 3: Implement CalendarService

**Files:**
- Create: `Sources/MeetingReminderApp/Calendar/CalendarService.swift`

**Step 1: Add EventKit store**

Create a `CalendarService` using `EKEventStore`.

**Step 2: Implement permission request**

For macOS 14+, call:

```swift
requestFullAccessToEvents
```

Fallback to older access API is not required because the minimum target is macOS 14.

**Step 3: Fetch today's upcoming events**

Fetch events from:
- start: `now - 15 minutes`
- end: end of current day

Filter:
- exclude all-day events
- include active events
- include future events
- sort by start date

**Step 4: Observe calendar changes**

Listen for:

```swift
Notification.Name.EKEventStoreChanged
```

Expose updates to the view model.

**Step 5: Build**

Run:

```bash
swift build
```

Expected: build succeeds.

## Task 4: Implement Notifications

**Files:**
- Create: `Sources/MeetingReminderApp/Notifications/NotificationService.swift`
- Create: `Sources/MeetingReminderApp/Scheduling/ReminderScheduler.swift`

**Step 1: Request notification permission**

Use `UNUserNotificationCenter`.

Requested options:
- `alert`
- `sound`
- `badge` only if needed; default is no badge.

**Step 2: Schedule reminders**

For each upcoming event, schedule reminders at:
- `T-10`
- `T-5`
- `T=0`

Skip reminders whose fire date is already in the past.

**Step 3: Use stable notification IDs**

Use IDs based on:
- event ID
- reminder offset

This prevents duplicate notifications when the app refreshes every minute.

**Step 4: Cancel stale pending reminders**

When refreshing the event list, cancel pending notifications that no longer match the current upcoming events.

**Step 5: Build**

Run:

```bash
swift build
```

Expected: build succeeds.

## Task 5: Implement Menu Bar View Model

**Files:**
- Create: `Sources/MeetingReminderApp/MenuBar/MenuBarViewModel.swift`

**Step 1: Add observable state**

Track:
- calendar permission state
- notification permission state
- upcoming events
- selected next event
- last refresh time
- display title

**Step 2: Add refresh loop**

Start a 60-second timer after app launch.

Refresh triggers:
- app launch
- timer tick
- EventKit changed notification
- menu action `Refresh Now`

**Step 3: Connect reminders**

After every successful event refresh:
- update upcoming events
- reschedule reminders
- update menu bar title

**Step 4: Build**

Run:

```bash
swift build
```

Expected: build succeeds.

## Task 6: Implement Menu Bar UI

**Files:**
- Create: `Sources/MeetingReminderApp/MenuBar/MenuBarView.swift`
- Modify: `Sources/MeetingReminderApp/App/MeetingReminderApp.swift`

**Step 1: Add compact menu bar label**

Use the view model's display title as the `MenuBarExtra` label.

Expected examples:
- `No meetings`
- `Team Standup in 8m`
- `Client Review now`

**Step 2: Add dropdown content**

Dropdown sections:
- permission warning if Calendar access is denied
- next meeting summary
- upcoming meetings today
- `Refresh Now`
- `Open Calendar`
- `Quit`

**Step 3: Keep UI minimal**

No settings screen in V1.

**Step 4: Build**

Run:

```bash
swift build
```

Expected: build succeeds.

## Task 7: Add App Packaging

**Files:**
- Create: `scripts/build-app.sh`
- Create: `scripts/build-dmg.sh`

**Step 1: Build release executable**

`scripts/build-app.sh` should run:

```bash
swift build -c release
```

**Step 2: Create `.app` bundle**

Create:

```text
dist/Meeting Reminder.app
dist/Meeting Reminder.app/Contents/MacOS/MeetingReminderApp
dist/Meeting Reminder.app/Contents/Info.plist
dist/Meeting Reminder.app/Contents/Resources
```

Copy the release executable and plist into the bundle.

**Step 3: Sign ad hoc for local testing**

Use:

```bash
codesign --force --deep --sign - "dist/Meeting Reminder.app"
```

This is not equivalent to Developer ID signing, but it improves local app bundle behavior.

**Step 4: Create DMG**

Use `hdiutil create` to package the app:

```bash
hdiutil create -volname "Meeting Reminder" -srcfolder "dist/Meeting Reminder.app" -ov -format UDZO "dist/MeetingReminder.dmg"
```

**Step 5: Verify app bundle**

Run:

```bash
open "dist/Meeting Reminder.app"
```

Expected: menu bar app appears and requests permissions as needed.

## Task 8: Add Documentation

**Files:**
- Create: `README.md`

**Step 1: Explain scope**

README should state:
- reads local macOS Calendar events
- does not connect directly to Google Calendar
- requires Google Calendar to be synced into macOS Calendar
- no App Store support

**Step 2: Add build commands**

Include:

```bash
swift build
./scripts/build-app.sh
./scripts/build-dmg.sh
```

**Step 3: Add permissions notes**

Document:
- Calendar permission
- Notifications permission
- how to reset permissions during development

**Step 4: Add distribution caveat**

Explain:
- GitHub DMG works
- unsigned or unnotarized apps may show macOS security warnings
- Developer ID signing and notarization are V2

## Task 9: Manual Verification

**Files:**
- No code files.

**Step 1: Build release**

Run:

```bash
./scripts/build-app.sh
```

Expected: `.app` bundle exists in `dist`.

**Step 2: Launch app**

Run:

```bash
open "dist/Meeting Reminder.app"
```

Expected:
- app appears in menu bar
- Calendar permission prompt appears if not granted
- Notification permission prompt appears if not granted

**Step 3: Verify event display**

Create or identify a test event in macOS Calendar within the next 10 minutes.

Expected:
- menu bar shows the event title and countdown
- dropdown shows the event in today's list

**Step 4: Verify notifications**

Create test events at:
- 10 minutes from now
- 5 minutes from now
- 1 minute from now

Expected:
- reminders fire once per configured offset
- refresh does not duplicate pending notifications

**Step 5: Build DMG**

Run:

```bash
./scripts/build-dmg.sh
```

Expected:
- `dist/MeetingReminder.dmg` exists
- opening DMG shows the app bundle

## Acceptance Criteria

- `swift build` passes.
- `.app` bundle launches from Finder or `open`.
- App runs as menu bar only.
- App requests Calendar access.
- App requests Notification access.
- App lists today's upcoming non-all-day events.
- Menu bar text updates within 60 seconds.
- Reminder notifications fire at `T-10`, `T-5`, and `T=0`.
- Repeated refreshes do not create duplicate notifications.
- `scripts/build-dmg.sh` creates a usable DMG.
- README explains that Google Calendar must be synced through macOS Calendar.

## V2 Candidates

- Custom persistent popup at `T-5` or `T=0`.
- Launch at login.
- Calendar picker.
- Configurable reminder offsets.
- Developer ID signing and notarization.
- Direct Google Calendar API mode.
