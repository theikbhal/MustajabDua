import Foundation
import UserNotifications

/// One daily local notification reminding you to read the Nawabi Nuskha.
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var reminderOn: Bool {
        didSet {
            UserDefaults.standard.set(reminderOn, forKey: Keys.reminderOn)
            if reminderOn { schedule() } else { cancel() }
        }
    }
    @Published var reminderHour: Int {
        didSet { UserDefaults.standard.set(reminderHour, forKey: Keys.hour); scheduleIfOn() }
    }
    @Published var reminderMinute: Int {
        didSet { UserDefaults.standard.set(reminderMinute, forKey: Keys.minute); scheduleIfOn() }
    }

    private enum Keys {
        static let reminderOn = "reminders.on"
        static let hour = "reminders.hour"
        static let minute = "reminders.minute"
        static let identifier = "mustajabdua.daily"
        static let testIdentifier = "mustajabdua.test"
    }

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.reminderOn) == nil {
            reminderOn = true
            reminderHour = 7
            reminderMinute = 0
        } else {
            reminderOn = defaults.bool(forKey: Keys.reminderOn)
            reminderHour = defaults.integer(forKey: Keys.hour)
            reminderMinute = defaults.integer(forKey: Keys.minute)
        }
        checkAuthorization()
    }

    var reminderTimeText: String {
        String(format: "%02d:%02d", reminderHour, reminderMinute)
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted && self.reminderOn { self.schedule() }
            }
        }
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional
            }
        }
    }

    func scheduleIfOn() {
        guard reminderOn else { return }
        if isAuthorized { schedule() } else { checkAuthorization() }
    }

    func schedule() {
        guard reminderOn, isAuthorized else { return }
        cancel()

        let target = UserDefaults.standard.integer(forKey: "dua.target")
        let count = target == 27 ? 27 : 25

        let content = UNMutableNotificationContent()
        content.title = "🕌 Mustajab ud Dua — Nawabi Nuskha"
        content.body = "Read the dua \(count) times today: Allahummaghfir lee wa lil mu'mineena…"
        content.sound = .default

        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Keys.identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Keys.identifier])
    }

    func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = "🕌 Mustajab ud Dua test"
        content.body = "Reminders work — one daily notification at \(reminderTimeText)."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: Keys.testIdentifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
