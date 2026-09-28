import Foundation
import SwiftUI

final class AppState: ObservableObject {
    enum Tab: String, CaseIterable, Identifiable {
        case counter, history, help, settings
        var id: String { rawValue }

        var title: String {
            switch self {
            case .counter: "Counter"
            case .history: "History"
            case .help: "Help"
            case .settings: "Settings"
            }
        }

        var symbol: String {
            switch self {
            case .counter: "circle.circle.fill"
            case .history: "calendar"
            case .help: "questionmark.circle"
            case .settings: "gearshape"
            }
        }
    }

    @Published var tab: Tab = .counter
    @Published var showOnboarding: Bool
    @Published var showOnboardingAgain: Bool {
        didSet { UserDefaults.standard.set(showOnboardingAgain, forKey: Keys.onboardingRepeat) }
    }

    private enum Keys {
        static let onboardingDone = "onboarding.done"
        static let onboardingRepeat = "onboarding.repeat"
    }

    init() {
        let repeatOnboarding = UserDefaults.standard.bool(forKey: Keys.onboardingRepeat)
        showOnboardingAgain = repeatOnboarding
        showOnboarding = !UserDefaults.standard.bool(forKey: Keys.onboardingDone) || repeatOnboarding
    }

    func finishOnboarding() {
        UserDefaults.standard.set(!showOnboardingAgain, forKey: Keys.onboardingDone)
        withAnimation(.easeInOut(duration: 0.25)) { showOnboarding = false }
    }
}
