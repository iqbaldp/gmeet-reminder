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
    @Published private(set) var launchAtLoginEnabled = false
    @Published private(set) var launchAtLoginStatusText = "Launch at login disabled"
    @Published private(set) var launchAtLoginErrorText: String?

    let popupSettingsStore: PopupSettingsStore

    private let calendarService: CalendarService
    private let notificationService: NotificationService
    private let launchAtLoginService: LaunchAtLoginService
    private let popupPresenter: PopupPresenter
    private let shownPopupIdentifiersKey = "shownPopupIdentifiers"
    private var refreshTimer: Timer?
    private var calendarObserver: NSObjectProtocol?
    private var hasStarted = false
    private var shownPopupIdentifiers: Set<String>

    init() {
        calendarService = CalendarService()
        notificationService = NotificationService()
        launchAtLoginService = LaunchAtLoginService()
        popupSettingsStore = PopupSettingsStore()
        popupPresenter = PopupPresenter()
        shownPopupIdentifiers = Set(UserDefaults.standard.stringArray(forKey: shownPopupIdentifiersKey) ?? [])
        refreshLaunchAtLoginState()
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

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
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

        showDuePopups(events: events, now: now)

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

    func setLaunchAtLoginEnabled(_ enabled: Bool) {
        do {
            try launchAtLoginService.setEnabled(enabled)
            launchAtLoginErrorText = nil
        } catch {
            launchAtLoginErrorText = error.localizedDescription
        }

        refreshLaunchAtLoginState()
    }

    private func bootstrap() async {
        calendarPermissionState = await calendarService.requestAccessIfNeeded()
        notificationPermissionState = await notificationService.requestAccessIfNeeded()
        await refresh()
    }

    private func showDuePopups(events: [CalendarEvent], now: Date) {
        let duePopups = PopupScheduler.duePopups(
            for: events,
            offsets: popupSettingsStore.offsets,
            shownIdentifiers: shownPopupIdentifiers,
            now: now
        )

        for popup in duePopups {
            shownPopupIdentifiers.insert(popup.identifier)
            popupPresenter.show(popup) { [weak self] in
                self?.openCalendar()
            }
        }

        persistShownPopupIdentifiers()
    }

    private func persistShownPopupIdentifiers() {
        let identifiers = Array(shownPopupIdentifiers)

        if identifiers.count > 500 {
            shownPopupIdentifiers = Set(identifiers.suffix(250))
        }

        UserDefaults.standard.set(Array(shownPopupIdentifiers), forKey: shownPopupIdentifiersKey)
    }

    private func refreshLaunchAtLoginState() {
        launchAtLoginEnabled = launchAtLoginService.isEnabled
        launchAtLoginStatusText = launchAtLoginService.statusText
    }
}
