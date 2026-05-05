import XCTest
@testable import MeetingReminderCore

final class ReminderSchedulerTests: XCTestCase {
    func testReminderPlansSkipPastOffsetsAndUseStableIdentifiers() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let event = CalendarEvent(
            id: "event-1",
            title: "Planning",
            startDate: now.addingTimeInterval(360),
            endDate: now.addingTimeInterval(1_200),
            calendarTitle: "Work",
            isAllDay: false,
            url: nil
        )

        let plans = ReminderScheduler.plans(
            for: [event],
            offsets: [.minutesBefore(10), .minutesBefore(5), .atStart],
            now: now
        )

        XCTAssertEqual(plans.map(\.identifier), ["event-1--5m", "event-1-start"])
        XCTAssertEqual(plans.map(\.title), ["Planning in 5 minutes", "Planning is starting now"])
    }
}
