import Foundation

public struct CalendarEvent: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let calendarTitle: String
    public let isAllDay: Bool
    public let url: URL?

    public init(
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        calendarTitle: String,
        isAllDay: Bool,
        url: URL?
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.calendarTitle = calendarTitle
        self.isAllDay = isAllDay
        self.url = url
    }

    public var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? "Untitled Meeting" : trimmedTitle
    }

    public func isActive(now: Date) -> Bool {
        startDate <= now && endDate > now
    }

    public func startsWithin(minutes: Int, now: Date) -> Bool {
        let interval = startDate.timeIntervalSince(now)
        return interval >= 0 && interval <= TimeInterval(minutes * 60)
    }
}
