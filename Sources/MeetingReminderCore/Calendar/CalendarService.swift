import EventKit
import Foundation

public enum CalendarPermissionState: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case writeOnly
    case unknown

    public var canReadEvents: Bool {
        self == .authorized
    }

    public var displayText: String {
        switch self {
        case .notDetermined:
            return "Calendar access has not been requested"
        case .authorized:
            return "Calendar access granted"
        case .denied:
            return "Calendar access denied"
        case .restricted:
            return "Calendar access restricted"
        case .writeOnly:
            return "Calendar access is write-only"
        case .unknown:
            return "Calendar access is unavailable"
        }
    }
}

@MainActor
public final class CalendarService {
    private let eventStore: EKEventStore

    public init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    public var permissionState: CalendarPermissionState {
        Self.mapAuthorizationStatus(EKEventStore.authorizationStatus(for: .event))
    }

    public func requestAccessIfNeeded() async -> CalendarPermissionState {
        let currentState = permissionState

        guard currentState == .notDetermined || currentState == .writeOnly else {
            return currentState
        }

        return await withCheckedContinuation { continuation in
            eventStore.requestFullAccessToEvents { granted, _ in
                Task { @MainActor in
                    continuation.resume(returning: granted ? .authorized : self.permissionState)
                }
            }
        }
    }

    public func fetchUpcomingEvents(now: Date = Date()) -> [CalendarEvent] {
        let calendar = Calendar.current
        let startDate = now.addingTimeInterval(-15 * 60)
        let endDate = calendar.dateInterval(of: .day, for: now)?.end ?? now.addingTimeInterval(24 * 60 * 60)
        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)

        return eventStore.events(matching: predicate)
            .filter { event in
                !event.isAllDay && event.endDate > now
            }
            .map { event in
                let meetingURL = MeetingLinkExtractor.extract(
                    url: event.url,
                    location: event.location,
                    notes: event.notes
                )

                return CalendarEvent(
                    id: event.eventIdentifier ?? event.calendarItemIdentifier,
                    title: event.title ?? "",
                    startDate: event.startDate,
                    endDate: event.endDate,
                    calendarTitle: event.calendar.title,
                    isAllDay: event.isAllDay,
                    url: meetingURL
                )
            }
            .sorted { left, right in
                if left.startDate == right.startDate {
                    return left.displayTitle < right.displayTitle
                }

                return left.startDate < right.startDate
            }
    }

    public func observeChanges(_ handler: @escaping @MainActor () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: eventStore,
            queue: .main
        ) { _ in
            Task { @MainActor in
                handler()
            }
        }
    }

    public func stopObserving(_ observer: NSObjectProtocol?) {
        guard let observer else {
            return
        }

        NotificationCenter.default.removeObserver(observer)
    }

    private static func mapAuthorizationStatus(_ status: EKAuthorizationStatus) -> CalendarPermissionState {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized, .fullAccess:
            return .authorized
        case .writeOnly:
            return .writeOnly
        @unknown default:
            return .unknown
        }
    }
}
