import SwiftUI
import UserNotifications

@main
struct MustajabDuaApp: App {
    @StateObject private var state = AppState()
    @StateObject private var store = DuaStore()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationManager.shared.scheduleIfOn()
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if state.showOnboarding {
                    OnboardingView()
                } else {
                    RootView()
                }
            }
            .environmentObject(state)
            .environmentObject(store)
            .frame(minWidth: 720, minHeight: 520)
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
                NotificationManager.shared.checkAuthorization()
                NotificationManager.shared.scheduleIfOn()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    NotificationManager.shared.checkAuthorization()
                }
            }
        }
        .defaultSize(width: 860, height: 620)
        .defaultPosition(.center)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Counter") { state.tab = .counter }.keyboardShortcut("1", modifiers: .command)
                Button("History") { state.tab = .history }.keyboardShortcut("2", modifiers: .command)
                Button("Help") { state.tab = .help }.keyboardShortcut("3", modifiers: .command)
                Button("Settings") { state.tab = .settings }.keyboardShortcut("4", modifiers: .command)
            }
        }
    }
}
