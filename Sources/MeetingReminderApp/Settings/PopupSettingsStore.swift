import Foundation
import MeetingReminderCore

@MainActor
final class PopupSettingsStore: ObservableObject {
    static let supportedOffsets = [10, 5, 1, 0]

    @Published private(set) var offsetsInMinutes: [Int]

    private let defaults: UserDefaults
    private let key = "popupOffsetsInMinutes"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedOffsets = defaults.array(forKey: key) as? [Int] ?? []
        let normalizedOffsets = PopupScheduler.normalizedOffsets(storedOffsets)
        offsetsInMinutes = normalizedOffsets.isEmpty ? PopupScheduler.defaultOffsets : normalizedOffsets
    }

    func isEnabled(_ offset: Int) -> Bool {
        offsetsInMinutes.contains(offset)
    }

    func setOffset(_ offset: Int, isEnabled: Bool) {
        var offsets = Set(offsetsInMinutes)

        if isEnabled {
            offsets.insert(offset)
        } else {
            offsets.remove(offset)
        }

        offsetsInMinutes = PopupScheduler.normalizedOffsets(Array(offsets))
        defaults.set(offsetsInMinutes, forKey: key)
    }

    func resetDefaults() {
        offsetsInMinutes = PopupScheduler.defaultOffsets
        defaults.set(offsetsInMinutes, forKey: key)
    }
}
