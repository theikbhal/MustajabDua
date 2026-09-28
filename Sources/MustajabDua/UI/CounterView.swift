import SwiftUI
import AppKit

struct CounterView: View {
    @EnvironmentObject var store: DuaStore
    @State private var eventMonitor: Any?

    private var progress: Double {
        guard store.target > 0 else { return 0 }
        return min(1.0, Double(store.todayCount) / Double(store.target))
    }

    private var done: Bool { store.completedToday }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                duaCard
                ring
                controls
                stats
            }
            .padding(26)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(alignment: .top) { Color.clear }
        .onAppear(perform: addMonitor)
        .onDisappear(perform: removeMonitor)
    }

    // MARK: - Dua card

    private var duaCard: some View {
        VStack(spacing: 8) {
            Text(DuaText.arabic)
                .font(.system(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, .rightToLeft)
                .frame(maxWidth: .infinity)

            Text(DuaText.transliteration)
                .font(.title3.italic())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(DuaText.translation)
                .font(.callout)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Text(DuaText.hadith)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Ring

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.green.opacity(0.15), lineWidth: 18)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    done ? Color.green : Color.green.opacity(0.85),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.35), value: progress)

            VStack(spacing: 4) {
                Text("\(store.todayCount)")
                    .font(.system(size: 68, weight: .bold, design: .rounded))
                Text("of \(store.target) times")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                if done {
                    Text("Completed ✅")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.green)
                } else {
                    Text("\(store.remaining) to go")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(width: 250, height: 250)
        .contentShape(Circle())
        .onTapGesture { bump(+1) }
        .help("Click or press Space to count")
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                bump(-1)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .disabled(store.todayCount == 0)
            .help("Undo last (or press −)")

            Button {
                bump(+1)
            } label: {
                Label("Count 1", systemImage: "plus.circle.fill")
                    .font(.title3.weight(.semibold))
                    .frame(minWidth: 150)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(done ? .green : .accentColor)
            .keyboardShortcut(.return, modifiers: [])
            .help("Count one recitation (Space or Return)")

            Button("Reset") {
                withAnimation { store.resetToday() }
            }
            .buttonStyle(.bordered)
            .disabled(store.todayCount == 0)
            .help("Clear today's count")
        }
    }

    // MARK: - Stats

    private var stats: some View {
        HStack(spacing: 14) {
            statBadge(symbol: "flame.fill", title: "Streak", value: "\(store.streak) day\(store.streak == 1 ? "" : "s")")
            statBadge(symbol: "checkmark.seal.fill", title: "Completed days", value: "\(store.totalDaysCompleted)")
            statBadge(symbol: "sum", title: "All-time recitations", value: "\(store.totalRecitations)")
        }
    }

    private func statBadge(symbol: String, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private func bump(_ delta: Int) {
        withAnimation(.spring(duration: 0.25)) {
            if delta > 0 {
                for _ in 0..<delta { store.increment() }
            } else {
                for _ in 0..<(-delta) { store.decrement() }
            }
        }
        if delta > 0 && store.completedToday {
            NSSound.beep()
        }
    }

    // MARK: - Keyboard

    private func addMonitor() {
        guard eventMonitor == nil else { return }
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard !Self.isEditingText else { return event }
            switch event.keyCode {
            case 49, 36: // space, return
                bump(+1)
                return nil
            case 27: // escape → undo
                bump(-1)
                return nil
            default:
                return event
            }
        }
    }

    private func removeMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private static var isEditingText: Bool {
        guard let responder = NSApp.keyWindow?.firstResponder else { return false }
        return responder is NSTextView || responder is NSText
    }
}
