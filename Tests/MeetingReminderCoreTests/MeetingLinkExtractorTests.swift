import XCTest
@testable import MeetingReminderCore

final class MeetingLinkExtractorTests: XCTestCase {
    func testExtractsGoogleMeetLinkFromNotes() {
        let url = MeetingLinkExtractor.extract(
            url: nil,
            location: nil,
            notes: "Join with Google Meet: https://meet.google.com/abc-defg-hij"
        )

        XCTAssertEqual(url?.absoluteString, "https://meet.google.com/abc-defg-hij")
    }

    func testPrefersKnownMeetingLinkOverGenericEventURL() {
        let url = MeetingLinkExtractor.extract(
            url: URL(string: "https://calendar.google.com/calendar/event?eid=123"),
            location: "https://zoom.us/j/123456789",
            notes: nil
        )

        XCTAssertEqual(url?.absoluteString, "https://zoom.us/j/123456789")
    }
}
