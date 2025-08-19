import UserNotifications

enum LocalNotifications {
    static func requestPermission() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    static func scheduleDaily(at components: DateComponents, id: String = "daily-goal") async throws {
        let center = UNUserNotificationCenter.current()
        await cancel(id: id)
        let content = UNMutableNotificationContent()
        content.title = "JapaneseBuddy"
        content.body = "Time for today’s practice!"
        var comps = DateComponents()
        comps.hour = components.hour
        comps.minute = components.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(req)
    }

    static func cancel(id: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
