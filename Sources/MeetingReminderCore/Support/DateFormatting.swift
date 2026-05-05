import Foundation

public enum MeetingDisplayFormatter {
    public static func menuBarTitle(for event: CalendarEvent?, now: Date) -> String {
        guard let event else {
            return "No meetings"
        }

        if event.isActive(now: now) {
            return "\(event.displayTitle) now"
        }

        let minutesUntilStart = max(0, Int(ceil(event.startDate.timeIntervalSince(now) / 60)))

        if minutesUntilStart < 60 {
            return "\(event.displayTitle) in \(minutesUntilStart)m"
        }

        return "\(event.displayTitle) at \(timeString(for: event.startDate))"
    }

    public static func dropdownTimeRange(for event: CalendarEvent) -> String {
        "\(timeString(for: event.startDate)) - \(timeString(for: event.endDate))"
    }

    public static func lastRefreshText(for date: Date?) -> String {
        guard let date else {
            return "Never refreshed"
        }

        return "Last refreshed \(timeString(for: date))"
    }

    private static func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
