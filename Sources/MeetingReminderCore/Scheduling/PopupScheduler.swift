import Foundation

public struct PopupOffset: Hashable, Sendable {
    public let secondsBeforeStart: Int

    public var identifierSuffix: String {
        if secondsBeforeStart == 0 {
            return "start"
        }

        if secondsBeforeStart % 60 == 0 {
            return "\(secondsBeforeStart / 60)m"
        }

        return "\(secondsBeforeStart)s"
    }

    public var displayText: String {
        if secondsBeforeStart == 0 {
            return "At meeting start"
        }

        if secondsBeforeStart % 60 == 0 {
            let minutes = secondsBeforeStart / 60
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") before"
        }

        return "\(secondsBeforeStart) \(secondsBeforeStart == 1 ? "second" : "seconds") before"
    }

    public static func minutes(_ minutes: Int) -> PopupOffset {
        PopupOffset(secondsBeforeStart: minutes * 60)
    }

    public static func seconds(_ seconds: Int) -> PopupOffset {
        PopupOffset(secondsBeforeStart: seconds)
    }
}

public struct PopupPlan: Hashable, Sendable {
    public let identifier: String
    public let event: CalendarEvent
    public let offset: PopupOffset
    public let triggerDate: Date

    public var title: String {
        event.displayTitle
    }

    public init(identifier: String, event: CalendarEvent, offset: PopupOffset, triggerDate: Date) {
        self.identifier = identifier
        self.event = event
        self.offset = offset
        self.triggerDate = triggerDate
    }
}

public enum PopupScheduler {
    public static let defaultOffsets: [PopupOffset] = [.minutes(5), .minutes(1)]

    public static func duePopups(
        for events: [CalendarEvent],
        offsets: [PopupOffset] = defaultOffsets,
        shownIdentifiers: Set<String>,
        now: Date,
        triggerWindow: TimeInterval = 15
    ) -> [PopupPlan] {
        normalizedOffsets(offsets).flatMap { offset in
            events.compactMap { event in
                let triggerDate = event.startDate.addingTimeInterval(TimeInterval(-offset.secondsBeforeStart))
                let triggerDeadline = triggerDate.addingTimeInterval(triggerWindow)
                let identifier = identifier(for: event, offset: offset)

                guard now >= triggerDate && now <= triggerDeadline && !shownIdentifiers.contains(identifier) else {
                    return nil
                }

                return PopupPlan(
                    identifier: identifier,
                    event: event,
                    offset: offset,
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

    public static func identifier(for event: CalendarEvent, offset: PopupOffset) -> String {
        "\(event.id)-popup-\(offset.identifierSuffix)"
    }

    public static func normalizedOffsets(_ offsets: [PopupOffset]) -> [PopupOffset] {
        Array(Set(offsets.filter { offset in
            offset.secondsBeforeStart >= 0 && offset.secondsBeforeStart <= 60 * 60
        }))
        .sorted { left, right in
            left.secondsBeforeStart > right.secondsBeforeStart
        }
    }
}
