import XCTest
@testable import MeetingReminderCore

final class PopupSchedulerTests: XCTestCase {
    func testDefaultPopupOffsetsAreFiveAndOneMinutesBeforeStart() {
        XCTAssertEqual(PopupScheduler.defaultOffsets, [5, 1])
    }

    func testDuePopupsIncludeOffsetsInsideTriggerWindow() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let event = CalendarEvent(
            id: "event-1",
            title: "Design Review",
            startDate: now.addingTimeInterval(280),
            endDate: now.addingTimeInterval(1_800),
            calendarTitle: "Work",
            isAllDay: false,
            url: nil
        )

        let popups = PopupScheduler.duePopups(
            for: [event],
            offsetsInMinutes: [5, 1],
            shownIdentifiers: [],
            now: now,
            triggerWindow: 60
        )

        XCTAssertEqual(popups.map(\.identifier), ["event-1-popup-5m"])
        XCTAssertEqual(popups.first?.title, "Design Review")
        XCTAssertEqual(popups.first?.minutesBeforeStart, 5)
    }

    func testDuePopupsSkipAlreadyShownIdentifiers() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let event = CalendarEvent(
            id: "event-1",
            title: "Design Review",
            startDate: now.addingTimeInterval(280),
            endDate: now.addingTimeInterval(1_800),
            calendarTitle: "Work",
            isAllDay: false,
            url: nil
        )

        let popups = PopupScheduler.duePopups(
            for: [event],
            offsetsInMinutes: [5, 1],
            shownIdentifiers: ["event-1-popup-5m"],
            now: now,
            triggerWindow: 60
        )

        XCTAssertTrue(popups.isEmpty)
    }
}
