import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: DuaStore

    private let days = 14

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("History")
                    .font(.largeTitle.bold())

                HStack(spacing: 14) {
                    summary("Current streak", "\(store.streak) day\(store.streak == 1 ? "" : "s")", "flame.fill")
                    summary("Days completed", "\(store.totalDaysCompleted)", "checkmark.seal.fill")
                    summary("Total recitations", "\(store.totalRecitations)", "sum")
                }

                Text("Last \(days) days")
                    .font(.headline)
                    .padding(.top, 6)

                VStack(spacing: 8) {
                    ForEach(store.recentDays(days), id: \.key) { day in
                        row(day)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 700, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func summary(_ title: String, _ value: String, _ symbol: String) -> some View {
        VStack(spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value).font(.title3.weight(.semibold))
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }

    private func row(_ day: (date: Date, key: String, count: Int)) -> some View {
        let done = day.count >= store.target
        return HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : .secondary)

            Text(day.date, format: .dateTime.weekday(.wide).month().day())
                .font(.callout)

            if Calendar.current.isDateInToday(day.date) {
                Text("Today")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(.green.opacity(0.15), in: Capsule())
                    .foregroundStyle(.green)
            }

            Spacer()

            Text("\(day.count) / \(store.target)")
                .font(.callout.monospacedDigit())
                .foregroundStyle(day.count > 0 ? .primary : .tertiary)

            if done {
                Image(systemName: "star.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.quaternary.opacity(0.25), in: RoundedRectangle(cornerRadius: 10))
    }
}
