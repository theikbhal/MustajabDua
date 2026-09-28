import SwiftUI

struct SettingsPane: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var store: DuaStore
    @ObservedObject private var notifications = NotificationManager.shared
    @State private var confirmClear = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Settings")
                    .font(.largeTitle.bold())

                section("Dua target") {
                    Picker("Times per day", selection: $store.target) {
                        Text("25 times").tag(25)
                        Text("27 times").tag(27)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    Text("Both counts are reported in the hadith. Changing the target re-evaluates streaks and history.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                section("Daily reminder") {
                    Toggle("Daily reminder notification", isOn: $notifications.reminderOn)
                        .toggleStyle(.switch)

                    if notifications.reminderOn {
                        DatePicker(
                            "Reminder time",
                            selection: reminderTime,
                            displayedComponents: .hourAndMinute
                        )

                        if notifications.isAuthorized {
                            Label("Notifications allowed", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.callout)
                        } else {
                            Button {
                                notifications.requestAuthorization()
                            } label: {
                                Label("Allow notifications", systemImage: "bell.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }

                        HStack {
                            Button("Send test notification") { notifications.sendTest() }
                                .buttonStyle(.bordered)
                            Text("Fires in 2 seconds.")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Text("Reminders are scheduled locally by macOS. Nothing is sent over the network.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                section("Today") {
                    HStack {
                        Stepper("Today's count: \(store.todayCount)",
                                value: Binding(
                                    get: { store.todayCount },
                                    set: { store.setToday($0) }
                                ),
                                in: 0...999)
                        Spacer()
                        Button("Reset today", role: .destructive) {
                            store.resetToday()
                        }
                        .buttonStyle(.bordered)
                        .disabled(store.todayCount == 0)
                    }
                }

                section("Onboarding") {
                    Toggle("Show onboarding on next launch", isOn: $state.showOnboardingAgain)
                        .toggleStyle(.checkbox)
                    Button("Show onboarding now") {
                        state.showOnboarding = true
                    }
                    .buttonStyle(.bordered)
                }

                section("Data") {
                    HStack {
                        Button("Clear all history", role: .destructive) {
                            confirmClear = true
                        }
                        .buttonStyle(.bordered)
                        .confirmationDialog(
                            "Delete all counts and streak data?",
                            isPresented: $confirmClear
                        ) {
                            Button("Delete everything", role: .destructive) { store.clearAll() }
                            Button("Cancel", role: .cancel) {}
                        }
                        Spacer()
                        Text("\(store.totalRecitations) recitations · \(store.totalDaysCompleted) completed days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                section("About") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MustajabDua 1.0.0")
                            .font(.callout.weight(.semibold))
                        Text("Nawabi Nuskha · daily mustajab dua counter · MIT license")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("github.com/theikbhal/MustajabDua")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Developed by Ikbhal · theikbhal@gmail.com")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 620, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var comps = DateComponents()
                comps.hour = notifications.reminderHour
                comps.minute = notifications.reminderMinute
                return Calendar.current.date(from: comps) ?? Date()
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                notifications.reminderHour = comps.hour ?? 7
                notifications.reminderMinute = comps.minute ?? 0
            }
        )
    }

    @ViewBuilder
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
