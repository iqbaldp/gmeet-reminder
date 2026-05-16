import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginService {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    var statusText: String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "Launch at login enabled"
        case .notRegistered:
            return "Launch at login disabled"
        case .requiresApproval:
            return "Launch at login needs approval in System Settings"
        case .notFound:
            return "Launch at login unavailable for this build"
        @unknown default:
            return "Launch at login status unknown"
        }
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
