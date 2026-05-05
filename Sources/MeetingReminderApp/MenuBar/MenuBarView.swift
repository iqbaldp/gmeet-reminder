import SwiftUI
import MeetingReminderCore

struct MenuBarView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    @ObservedObject var popupSettingsStore: PopupSettingsStore

    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.calendarPermissionState.canReadEvents {
                Text(viewModel.calendarPermissionState.displayText)
            }

            if !viewModel.notificationPermissionState.canSendAlerts {
                Text(viewModel.notificationPermissionState.displayText)
            }

            if let nextEvent = viewModel.upcomingEvents.first {
                Section("Next Meeting") {
                    Text(nextEvent.displayTitle)
                    Text(MeetingDisplayFormatter.dropdownTimeRange(for: nextEvent))
                }
            }

            Section("Today") {
                if viewModel.upcomingEvents.isEmpty {
                    Text("No upcoming meetings")
                } else {
                    ForEach(viewModel.upcomingEvents) { event in
                        VStack(alignment: .leading) {
                            Text(event.displayTitle)
                            Text(MeetingDisplayFormatter.dropdownTimeRange(for: event))
                        }
                    }
                }
            }

            Divider()

            Section("Popup") {
                ForEach(PopupSettingsStore.supportedOffsets, id: \.self) { offset in
                    Toggle(popupOffsetLabel(for: offset), isOn: Binding(
                        get: {
                            popupSettingsStore.isEnabled(offset)
                        },
                        set: { isEnabled in
                            popupSettingsStore.setOffset(offset, isEnabled: isEnabled)
                        }
                    ))
                }

                Button("Reset Popup Defaults") {
                    popupSettingsStore.resetDefaults()
                }
            }

            Divider()

            Text(MeetingDisplayFormatter.lastRefreshText(for: viewModel.lastRefreshDate))

            Button(viewModel.isRefreshing ? "Refreshing..." : "Refresh Now") {
                Task {
                    await viewModel.refresh()
                }
            }
            .disabled(viewModel.isRefreshing)

            Button("Open Calendar") {
                viewModel.openCalendar()
            }

            Button("Quit") {
                viewModel.quit()
            }
        }
    }

    private func popupOffsetLabel(for offset: Int) -> String {
        if offset == 0 {
            return "At meeting start"
        }

        return "\(offset) minutes before"
    }
}
