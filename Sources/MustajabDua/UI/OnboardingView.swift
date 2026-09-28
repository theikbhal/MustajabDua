import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var store: DuaStore
    @ObservedObject private var notifications = NotificationManager.shared
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch page {
                case 0: welcome
                case 1: aboutDua
                case 2: howTo
                default: reminders
                }
            }
            .id(page)
            .transition(.opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index == page ? Color.green : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 14)

            Divider()

            HStack {
                Toggle(isOn: $state.showOnboardingAgain) {
                    Text("Show this onboarding on next launch")
                        .font(.callout)
                }
                .toggleStyle(.checkbox)

                Spacer()

                if page > 0 {
                    Button("Back") { page -= 1 }
                        .buttonStyle(.bordered)
                }

                if page < 3 {
                    Button("Next") { page += 1 }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                } else {
                    Button("Start reading") { state.finishOnboarding() }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(18)
        }
        .frame(width: 560, height: 520)
    }

    private func pageHeader(_ symbol: String, _ title: String, _ subtitle: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text(title).font(.title2.bold())
            Text(subtitle).font(.callout).foregroundStyle(.secondary)
        }
        .padding(.top, 28)
        .frame(maxWidth: .infinity)
    }

    private var welcome: some View {
        VStack(spacing: 16) {
            pageHeader("hands.clap.fill", "Mustajab ud Dua", "Nawabi Nuskha · a daily mustajab dua")
            Text(DuaText.arabic)
                .font(.system(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, .rightToLeft)
                .padding(.horizontal, 24)
            Text(DuaText.transliteration)
                .font(.callout.italic())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private var aboutDua: some View {
        VStack(spacing: 16) {
            pageHeader("book.closed.fill", "What is this nuskha?", "A dua the Prophet ﷺ taught for forgiveness")
            VStack(alignment: .leading, spacing: 12) {
                point("Read the dua 25 times — or 27 times — in one sitting.")
                point("It is called mustajab: Allah answers it for the one who reads it.")
                point("It asks forgiveness for you, for all believing men and women, and all Muslim men and women.")
                point(DuaText.hadith)
            }
            .padding(.horizontal, 34)
        }
    }

    private var howTo: some View {
        VStack(spacing: 16) {
            pageHeader("number.circle.fill", "How to use the app", "Count, keep a streak, read daily")
            VStack(alignment: .leading, spacing: 12) {
                point("Press Space (or click the ring) once per recitation.")
                point("Pick 25 or 27 as your target in Settings — the default is 25.")
                point("The ring resets at midnight; your streak grows with each completed day.")
                point("History shows the last 14 days; ⌘1–⌘4 switch tabs.")
            }
            .padding(.horizontal, 34)
        }
    }

    private var reminders: some View {
        VStack(spacing: 16) {
            pageHeader("bell.badge.fill", "Daily reminder", "One notification a day at your chosen time")
            VStack(alignment: .leading, spacing: 12) {
                point("Enable notifications so the app reminds you to read the dua daily.")
                point("Default reminder is 07:00 — change it any time in Settings.")
                point("Nothing leaves your Mac: reminders are scheduled locally.")
            }
            .padding(.horizontal, 34)

            if notifications.isAuthorized {
                Label("Reminders are enabled", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.callout)
            } else {
                Button {
                    notifications.requestAuthorization()
                } label: {
                    Label("Enable daily reminder", systemImage: "bell.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
    }

    private func point(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.callout)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
