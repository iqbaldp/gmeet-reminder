import AppKit
import Combine
import Foundation
import MeetingReminderCore

@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published private(set) var menuBarTitle = "Loading..."
    @Published private(set) var upcomingEvents: [CalendarEvent] = []
    @Published private(set) var calendarPermissionState: CalendarPermissionState = .notDetermined
    @Published private(set) var notificationPermissionState: NotificationPermissionState = .notDetermined
    @Published private(set) var lastRefreshDate: Date?
    @Published private(set) var isRefreshing = false

    private let calendarService: CalendarService
    private let notificationService: NotificationService
    private var refreshTimer: Timer?
    private var calendarObserver: NSObjectProtocol?
    private var hasStarted = false

    init() {
        calendarService = CalendarService()
        notificationService = NotificationService()
    }

    func start() {
        guard !hasStarted else {
            return
        }

        hasStarted = true

        calendarObserver = calendarService.observeChanges { [weak self] in
            Task { @MainActor in
                await self?.refresh()
            }
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }

        Task {
            await bootstrap()
        }
    }

    func refresh() async {
        isRefreshing = true
        defer {
            isRefreshing = false
        }

        let now = Date()
        calendarPermissionState = calendarService.permissionState

        guard calendarPermissionState.canReadEvents else {
            menuBarTitle = "Calendar access needed"
            upcomingEvents = []
            lastRefreshDate = now
            return
        }

        let events = calendarService.fetchUpcomingEvents(now: now)
        let plans = ReminderScheduler.plans(for: events, now: now)

        upcomingEvents = events
        menuBarTitle = MeetingDisplayFormatter.menuBarTitle(for: events.first, now: now)
        lastRefreshDate = now

        if notificationPermissionState.canSendAlerts {
            await notificationService.synchronize(plans: plans)
        }
    }

    func openCalendar() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Calendar.app"))
    }

    func quit() {
        NSApp.terminate(nil)
    }

    private func bootstrap() async {
        calendarPermissionState = await calendarService.requestAccessIfNeeded()
        notificationPermissionState = await notificationService.requestAccessIfNeeded()
        await refresh()
    }
}
