import AppKit
import Foundation
import MeetingReminderCore
import SwiftUI

@main
struct ScreenshotRenderer {
    @MainActor
    static func main() throws {
        let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "docs/assets")
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let events = demoEvents(now: now)
        let popup = PopupPlan(
            identifier: "demo-design-review-popup-1m",
            event: events[0],
            offset: .minutes(1),
            triggerDate: events[0].startDate.addingTimeInterval(-60)
        )

        try render(
            DemoMenuBarScreenshot(event: events[0], now: now),
            to: outputDirectory.appendingPathComponent("menu-bar.png"),
            size: CGSize(width: 1600, height: 420)
        )

        try render(
            DemoDropdownScreenshot(events: events, now: now),
            to: outputDirectory.appendingPathComponent("dropdown.png"),
            size: CGSize(width: 900, height: 980)
        )

        try render(
            DemoPopupScreenshot(popup: popup),
            to: outputDirectory.appendingPathComponent("popup.png"),
            size: CGSize(width: 720, height: 420)
        )
    }

    private static func demoEvents(now: Date) -> [CalendarEvent] {
        [
            CalendarEvent(
                id: "demo-design-review",
                title: "Design Review",
                startDate: now.addingTimeInterval(60),
                endDate: now.addingTimeInterval(1_860),
                calendarTitle: "Work",
                isAllDay: false,
                url: URL(string: "https://meet.google.com/demo-meet-link")
            ),
            CalendarEvent(
                id: "demo-weekly-sync",
                title: "Weekly Sync",
                startDate: now.addingTimeInterval(45 * 60),
                endDate: now.addingTimeInterval(75 * 60),
                calendarTitle: "Work",
                isAllDay: false,
                url: URL(string: "https://meet.google.com/demo-sync-link")
            )
        ]
    }

    @MainActor
    private static func render<Content: View>(_ view: Content, to outputURL: URL, size: CGSize) throws {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = 2

        guard let image = renderer.nsImage,
              let data = image.pngData else {
            throw RenderError.failed(outputURL.path)
        }

        try data.write(to: outputURL)
    }
}

private enum RenderError: Error {
    case failed(String)
}

private extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }

        return bitmap.representation(using: .png, properties: [:])
    }
}

private struct DemoMenuBarScreenshot: View {
    let event: CalendarEvent
    let now: Date

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 22) {
                Text("Finder")
                    .fontWeight(.semibold)
                Text("File")
                Text("Edit")
                Text("View")
                Spacer()
                Text(MeetingDisplayFormatter.menuBarTitle(for: event, now: now))
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                Text("Sat 16 May 21:24")
            }
            .font(.system(size: 15))
            .padding(.horizontal, 22)
            .frame(height: 42)
            .background(.bar)

            Spacer()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .environment(\.colorScheme, .light)
    }
}

private struct DemoDropdownScreenshot: View {
    let events: [CalendarEvent]
    let now: Date

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                GroupBox("Next Meeting") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(events[0].displayTitle)
                            .font(.headline)
                        Text(MeetingDisplayFormatter.dropdownTimeRange(for: events[0]))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Today") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(events) { event in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(event.displayTitle)
                                Text(MeetingDisplayFormatter.dropdownTimeRange(for: event))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()

                Toggle("Launch at Login", isOn: .constant(false))
                Text("Launch at login disabled")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                Toggle("5 minutes before", isOn: .constant(true))
                Toggle("1 minute before", isOn: .constant(true))
                Toggle("10 seconds before", isOn: .constant(false))

                Divider()

                Text(MeetingDisplayFormatter.lastRefreshText(for: now))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Refresh Now") {}
                Button("Open Calendar") {}
                Button("Quit") {}
            }
            .padding(20)
            .frame(width: 360)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
            .padding(40)

            Spacer()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .environment(\.colorScheme, .light)
    }
}

private struct DemoPopupScreenshot: View {
    let popup: PopupPlan

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Meeting starts \(popup.offset.displayText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(popup.event.displayTitle)
                        .font(.title3.weight(.semibold))
                        .lineLimit(2)

                    Text(MeetingDisplayFormatter.dropdownTimeRange(for: popup.event))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button("Dismiss") {}
                    Spacer()
                    Button("Open Meeting") {}
                }
            }
            .padding(20)
            .frame(width: 360)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .environment(\.colorScheme, .dark)
    }
}
