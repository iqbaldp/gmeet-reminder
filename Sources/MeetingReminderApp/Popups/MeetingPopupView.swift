import SwiftUI
import MeetingReminderCore

struct MeetingPopupView: View {
    let popup: PopupPlan
    let onDismiss: () -> Void
    let onOpenCalendar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(labelText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(popup.event.displayTitle)
                    .font(.title3.weight(.semibold))
                    .lineLimit(2)

                Text(MeetingDisplayFormatter.dropdownTimeRange(for: popup.event))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Dismiss") {
                    onDismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Open Calendar") {
                    onOpenCalendar()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private var labelText: String {
        if popup.minutesBeforeStart == 0 {
            return "Meeting is starting now"
        }

        return "Meeting starts in \(popup.minutesBeforeStart) minutes"
    }
}
