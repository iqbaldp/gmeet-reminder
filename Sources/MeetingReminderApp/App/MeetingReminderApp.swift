import SwiftUI

@main
struct MeetingReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel: MenuBarViewModel

    @MainActor
    init() {
        let viewModel = MenuBarViewModel()
        _viewModel = StateObject(wrappedValue: viewModel)
        viewModel.start()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel, popupSettingsStore: viewModel.popupSettingsStore)
        } label: {
            Text(viewModel.menuBarTitle)
        }
        .menuBarExtraStyle(.menu)
    }
}
