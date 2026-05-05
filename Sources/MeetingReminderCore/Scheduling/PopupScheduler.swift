import Foundation

public struct PopupPlan: Hashable, Sendable {
    public let identifier: String
    public let event: CalendarEvent
    public let minutesBeforeStart: Int
    public let triggerDate: Date

    public var title: String {
        event.displayTitle
    }

    public init(identifier: String, event: CalendarEvent, minutesBeforeStart: Int, triggerDate: Date) {
        self.identifier = identifier
        self.event = event
        self.minutesBeforeStart = minutesBeforeStart
        self.triggerDate = triggerDate
    }
}

public enum PopupScheduler {
    public static let defaultOffsets = [5, 1]

    public static func duePopups(
        for events: [CalendarEvent],
        offsetsInMinutes: [Int] = defaultOffsets,
        shownIdentifiers: Set<String>,
        now: Date,
        triggerWindow: TimeInterval = 75
    ) -> [PopupPlan] {
        normalizedOffsets(offsetsInMinutes).flatMap { offset in
            events.compactMap { event in
                let triggerDate = event.startDate.addingTimeInterval(TimeInterval(-offset * 60))
                let triggerDeadline = triggerDate.addingTimeInterval(triggerWindow)
                let identifier = identifier(for: event, minutesBeforeStart: offset)

                guard now >= triggerDate && now <= triggerDeadline && !shownIdentifiers.contains(identifier) else {
                    return nil
                }

                return PopupPlan(
                    identifier: identifier,
                    event: event,
                    minutesBeforeStart: offset,
                    triggerDate: triggerDate
                )
            }
        }
        .sorted { left, right in
            if left.triggerDate == right.triggerDate {
                return left.identifier < right.identifier
            }

            return left.triggerDate < right.triggerDate
        }
    }

    public static func identifier(for event: CalendarEvent, minutesBeforeStart: Int) -> String {
        "\(event.id)-popup-\(minutesBeforeStart)m"
    }

    public static func normalizedOffsets(_ offsets: [Int]) -> [Int] {
        Array(Set(offsets.filter { offset in
            offset >= 0 && offset <= 60
        }))
        .sorted(by: >)
    }
}
