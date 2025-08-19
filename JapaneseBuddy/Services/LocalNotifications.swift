import Foundation
import UserNotifications

enum LocalNotifications {
    private static let center = UNUserNotificationCenter.current()
    private static let identifier = "daily_reminder"

    static func apply(enabled: Bool, time: DateComponents?) {
        if !enabled { cancel() ; return }
        requestAuthorization { granted in
            guard granted, let time else { return }
            schedule(time: time)
        }
    }

    private static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }

    private static func schedule(time: DateComponents) {
        cancel()
        var comps = DateComponents()
        comps.hour = time.hour
        comps.minute = time.minute

        let content = UNMutableNotificationContent()
        content.title = "JapaneseBuddy"
        content.body = "Time to practice!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req, withCompletionHandler: nil)
    }

    private static func cancel() {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

