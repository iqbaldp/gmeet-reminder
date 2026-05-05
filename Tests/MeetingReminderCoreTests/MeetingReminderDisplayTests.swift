import XCTest
@testable import MeetingReminderCore

final class MeetingReminderDisplayTests: XCTestCase {
    func testMenuBarTitleShowsMinutesBeforeUpcomingMeeting() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let event = CalendarEvent(
            id: "event-1",
            title: "Dev Team x Support",
            startDate: now.addingTimeInterval(600),
            endDate: now.addingTimeInterval(2_400),
            calendarTitle: "Work",
            isAllDay: false,
            url: nil
        )

        XCTAssertEqual(MeetingDisplayFormatter.menuBarTitle(for: event, now: now), "Dev Team x Support in 10m")
    }

    func testMenuBarTitleShowsNowDuringActiveMeeting() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let event = CalendarEvent(
            id: "event-1",
            title: "Client Review",
            startDate: now.addingTimeInterval(-60),
            endDate: now.addingTimeInterval(1_800),
            calendarTitle: "Work",
            isAllDay: false,
            url: nil
        )

        XCTAssertEqual(MeetingDisplayFormatter.menuBarTitle(for: event, now: now), "Client Review now")
    }

    func testMenuBarTitleFallsBackWhenThereIsNoMeeting() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        XCTAssertEqual(MeetingDisplayFormatter.menuBarTitle(for: nil, now: now), "No meetings")
    }
}
