import Foundation
import MeetingReminderCore

@MainActor
final class PopupSettingsStore: ObservableObject {
    static let supportedOffsets: [PopupOffset] = [
        .minutes(10),
        .minutes(5),
        .minutes(1),
        .seconds(10),
        .seconds(0)
    ]

    @Published private(set) var offsets: [PopupOffset]

    private let defaults: UserDefaults
    private let secondsKey = "popupOffsetsInSeconds"
    private let legacyMinutesKey = "popupOffsetsInMinutes"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedSeconds = defaults.array(forKey: secondsKey) as? [Int] ?? []
        let legacyMinutes = defaults.array(forKey: legacyMinutesKey) as? [Int] ?? []
        let storedOffsets = storedSeconds.map(PopupOffset.seconds) + legacyMinutes.map(PopupOffset.minutes)
        let normalizedOffsets = PopupScheduler.normalizedOffsets(storedOffsets)
        offsets = normalizedOffsets.isEmpty ? PopupScheduler.defaultOffsets : normalizedOffsets
    }

    func isEnabled(_ offset: PopupOffset) -> Bool {
        offsets.contains(offset)
    }

    func setOffset(_ offset: PopupOffset, isEnabled: Bool) {
        var nextOffsets = Set(offsets)

        if isEnabled {
            nextOffsets.insert(offset)
        } else {
            nextOffsets.remove(offset)
        }

        offsets = PopupScheduler.normalizedOffsets(Array(nextOffsets))
        persist()
    }

    func resetDefaults() {
        offsets = PopupScheduler.defaultOffsets
        persist()
    }

    private func persist() {
        defaults.set(offsets.map(\.secondsBeforeStart), forKey: secondsKey)
        defaults.removeObject(forKey: legacyMinutesKey)
    }
}
