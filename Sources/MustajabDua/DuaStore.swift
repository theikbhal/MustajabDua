import Foundation
import SwiftUI

/// Local store: daily counts, target (25 or 27), streak.
final class DuaStore: ObservableObject {
    @Published var counts: [String: Int] { didSet { persist() } }
    @Published var target: Int { didSet { UserDefaults.standard.set(target, forKey: Keys.target) } }

    private enum Keys {
        static let counts = "dua.counts"
        static let target = "dua.target"
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init() {
        let savedTarget = UserDefaults.standard.integer(forKey: Keys.target)
        target = savedTarget == 25 || savedTarget == 27 ? savedTarget : 25
        if let data = UserDefaults.standard.data(forKey: Keys.counts),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            counts = decoded
        } else {
            counts = [:]
        }
    }

    // MARK: - Days

    static func dayKey(_ date: Date = Date()) -> String {
        dayFormatter.string(from: date)
    }

    var todayKey: String { Self.dayKey() }

    var todayCount: Int { counts[todayKey, default: 0] }

    var remaining: Int { max(0, target - todayCount) }

    var completedToday: Bool { todayCount >= target }

    func count(on day: Date) -> Int { counts[Self.dayKey(day), default: 0] }

    func isDone(on day: Date) -> Bool { count(on: day) >= target }

    // MARK: - Counting

    func increment() {
        counts[todayKey, default: 0] += 1
    }

    func decrement() {
        guard todayCount > 0 else { return }
        counts[todayKey] = todayCount - 1
    }

    func resetToday() {
        counts[todayKey] = 0
    }

    func setToday(_ value: Int) {
        counts[todayKey] = max(0, value)
    }

    // MARK: - Stats

    /// Consecutive days ending today (or yesterday, if today is not done yet) that hit the target.
    var streak: Int {
        var streak = 0
        var day = Date()
        if !completedToday { day = Calendar.current.date(byAdding: .day, value: -1, to: day)! }
        while isDone(on: day) {
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    var totalRecitations: Int {
        counts.values.reduce(0, +)
    }

    var totalDaysCompleted: Int {
        counts.values.filter { $0 >= target }.count
    }

    /// Most recent `days` days, newest first.
    func recentDays(_ days: Int) -> [(date: Date, key: String, count: Int)] {
        let calendar = Calendar.current
        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let key = Self.dayKey(date)
            return (date, key, counts[key, default: 0])
        }
    }

    func clearAll() {
        counts = [:]
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(counts) {
            UserDefaults.standard.set(data, forKey: Keys.counts)
        }
    }
}
