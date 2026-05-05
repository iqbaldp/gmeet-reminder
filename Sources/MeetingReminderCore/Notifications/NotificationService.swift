import Foundation
@preconcurrency import UserNotifications

public enum NotificationPermissionState: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case provisional
    case ephemeral
    case unknown

    public var canSendAlerts: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied, .unknown:
            return false
        }
    }

    public var displayText: String {
        switch self {
        case .notDetermined:
            return "Notification access has not been requested"
        case .authorized:
            return "Notifications enabled"
        case .denied:
            return "Notifications denied"
        case .provisional:
            return "Notifications enabled provisionally"
        case .ephemeral:
            return "Notifications enabled temporarily"
        case .unknown:
            return "Notification access is unavailable"
        }
    }
}

@MainActor
public final class NotificationService {
    private let center: UNUserNotificationCenter
    private let identifierPrefix = "meeting-reminder."

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    public func permissionState() async -> NotificationPermissionState {
        let center = center

        return await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: Self.mapAuthorizationStatus(settings.authorizationStatus))
            }
        }
    }

    public func requestAccessIfNeeded() async -> NotificationPermissionState {
        let currentState = await permissionState()

        guard currentState == .notDetermined else {
            return currentState
        }

        let center = center

        return await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in
                center.getNotificationSettings { settings in
                    continuation.resume(returning: Self.mapAuthorizationStatus(settings.authorizationStatus))
                }
            }
        }
    }

    public func synchronize(plans: [ReminderPlan]) async {
        let currentIdentifiers = Set(plans.map { identifierPrefix + $0.identifier })
        let pendingRequests = await pendingNotificationRequests()
        let staleIdentifiers = pendingRequests
            .map(\.identifier)
            .filter { identifier in
                identifier.hasPrefix(identifierPrefix) && !currentIdentifiers.contains(identifier)
            }

        if !staleIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: staleIdentifiers)
        }

        for plan in plans {
            await schedule(plan)
        }
    }

    private func schedule(_ plan: ReminderPlan) async {
        let content = UNMutableNotificationContent()
        content.title = plan.title
        content.body = plan.body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: plan.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifierPrefix + plan.identifier,
            content: content,
            trigger: trigger
        )

        await withCheckedContinuation { continuation in
            center.add(request) { _ in
                continuation.resume()
            }
        }
    }

    private func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    nonisolated private static func mapAuthorizationStatus(_ status: UNAuthorizationStatus) -> NotificationPermissionState {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        @unknown default:
            return .unknown
        }
    }
}
