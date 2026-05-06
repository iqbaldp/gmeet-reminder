import SwiftUI
import MeetingReminderCore

struct MeetingPopupView: View {
    let popup: PopupPlan
    let onDismiss: () -> Void
    let onOpenMeeting: () -> Void

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

                Button(openButtonTitle) {
                    onOpenMeeting()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private var labelText: String {
        if popup.offset.secondsBeforeStart == 0 {
            return "Meeting is starting now"
        }

        return "Meeting starts \(popup.offset.displayText)"
    }

    private var openButtonTitle: String {
        popup.event.url == nil ? "Open Calendar" : "Open Meeting"
    }
}
