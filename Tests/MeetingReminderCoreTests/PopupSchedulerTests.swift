import XCTest
@testable import MeetingReminderCore

final class PopupSchedulerTests: XCTestCase {
    func testDefaultPopupOffsetsAreFiveAndOneMinutesBeforeStart() {
        XCTAssertEqual(PopupScheduler.defaultOffsets.map(\.secondsBeforeStart), [300, 60])
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
            offsets: [.minutes(5), .minutes(1)],
            shownIdentifiers: [],
            now: now,
            triggerWindow: 60
        )

        XCTAssertEqual(popups.map(\.identifier), ["event-1-popup-5m"])
        XCTAssertEqual(popups.first?.title, "Design Review")
        XCTAssertEqual(popups.first?.offset.secondsBeforeStart, 300)
    }

    func testDuePopupsSupportTenSecondOffset() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let event = CalendarEvent(
            id: "event-1",
            title: "Daily",
            startDate: now.addingTimeInterval(8),
            endDate: now.addingTimeInterval(1_800),
            calendarTitle: "Work",
            isAllDay: false,
            url: nil
        )

        let popups = PopupScheduler.duePopups(
            for: [event],
            offsets: [.seconds(10)],
            shownIdentifiers: [],
            now: now,
            triggerWindow: 15
        )

        XCTAssertEqual(popups.map(\.identifier), ["event-1-popup-10s"])
        XCTAssertEqual(popups.first?.offset.displayText, "10 seconds before")
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
            offsets: [.minutes(5), .minutes(1)],
            shownIdentifiers: ["event-1-popup-5m"],
            now: now,
            triggerWindow: 60
        )

        XCTAssertTrue(popups.isEmpty)
    }
}
