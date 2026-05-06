import AppKit
import SwiftUI
import MeetingReminderCore

@MainActor
final class PopupPresenter {
    private var panels: [String: NSPanel] = [:]

    func show(_ popup: PopupPlan, openFallbackCalendar: @escaping () -> Void) {
        if panels[popup.identifier] != nil {
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 180),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )

        panel.title = "Meeting Reminder"
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        panel.contentView = NSHostingView(
            rootView: MeetingPopupView(
                popup: popup,
                onDismiss: { [weak self, weak panel] in
                    panel?.close()
                    self?.panels.removeValue(forKey: popup.identifier)
                },
                onOpenMeeting: { [weak self, weak panel] in
                    if let url = popup.event.url {
                        NSWorkspace.shared.open(url)
                    } else {
                        openFallbackCalendar()
                    }

                    panel?.close()
                    self?.panels.removeValue(forKey: popup.identifier)
                }
            )
        )

        panels[popup.identifier] = panel
        position(panel)
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else {
            panel.center()
            return
        }

        let frame = screen.visibleFrame
        let panelFrame = panel.frame
        let x = frame.maxX - panelFrame.width - 24
        let y = frame.maxY - panelFrame.height - 24
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
