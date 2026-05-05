import Foundation

public enum ReminderOffset: Hashable, Sendable {
    case minutesBefore(Int)
    case atStart

    public var secondsBeforeStart: TimeInterval {
        switch self {
        case .minutesBefore(let minutes):
            return TimeInterval(minutes * 60)
        case .atStart:
            return 0
        }
    }

    public var identifierSuffix: String {
        switch self {
        case .minutesBefore(let minutes):
            return "-\(minutes)m"
        case .atStart:
            return "start"
        }
    }

    public func title(for event: CalendarEvent) -> String {
        switch self {
        case .minutesBefore(let minutes):
            return "\(event.displayTitle) in \(minutes) minutes"
        case .atStart:
            return "\(event.displayTitle) is starting now"
        }
    }
}

public struct ReminderPlan: Hashable, Sendable {
    public let identifier: String
    public let eventID: String
    public let title: String
    public let body: String
    public let fireDate: Date

    public init(identifier: String, eventID: String, title: String, body: String, fireDate: Date) {
        self.identifier = identifier
        self.eventID = eventID
        self.title = title
        self.body = body
        self.fireDate = fireDate
    }
}

public enum ReminderScheduler {
    public static let defaultOffsets: [ReminderOffset] = [
        .minutesBefore(10),
        .minutesBefore(5),
        .atStart
    ]

    public static func plans(
        for events: [CalendarEvent],
        offsets: [ReminderOffset] = defaultOffsets,
        now: Date
    ) -> [ReminderPlan] {
        events.flatMap { event in
            offsets.compactMap { offset in
                let fireDate = event.startDate.addingTimeInterval(-offset.secondsBeforeStart)

                guard fireDate > now else {
                    return nil
                }

                return ReminderPlan(
                    identifier: "\(event.id)-\(offset.identifierSuffix)",
                    eventID: event.id,
                    title: offset.title(for: event),
                    body: MeetingDisplayFormatter.dropdownTimeRange(for: event),
                    fireDate: fireDate
                )
            }
        }
        .sorted { left, right in
            if left.fireDate == right.fireDate {
                return left.identifier < right.identifier
            }

            return left.fireDate < right.fireDate
        }
    }
}
