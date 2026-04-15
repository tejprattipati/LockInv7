import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var isAuthorized = false
    private init() {}

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            if granted { await scheduleAll(isWeighedIn: false, isFoodLogged: false) }
        } catch { isAuthorized = false }
    }

    func checkStatus() async {
        let s = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = s.authorizationStatus == .authorized
    }

    func scheduleAll(isWeighedIn: Bool, isFoodLogged: Bool) async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        await scheduleWeighIn(done: isWeighedIn)
        await scheduleMeals()
        await scheduleFoodLog(done: isFoodLogged)
        await scheduleWater()
        await scheduleCreatine()
        await scheduleNightlyWarning()
        await scheduleBedtime()
    }

    // MARK: - Weigh-in
    private func scheduleWeighIn(done: Bool) async {
        guard !done else { return }
        let slots: [(Int, Int, String, String)] = [
            (10, 0, "Time to weigh in.", "Step on the scale. Log it in LockIn."),
            (12, 0, "Still need your weigh-in.", "Get on the scale before the day moves on."),
            (18, 0, "Last chance: weigh in.", "You haven't logged your weight today.")
        ]
        for (i, (h, m, title, body)) in slots.enumerated() {
            await schedule(id: "weighin_\(i)", hour: h, minute: m, title: title, body: body, category: "WEIGH_IN")
        }
    }

    // MARK: - Meals
    private func scheduleMeals() async {
        await schedule(id: "meal1",    hour: 9,  minute: 0, title: "Meal 1 window.",         body: "Get your first meal in. Sets the tone for the day.")
        await schedule(id: "meal2",    hour: 13, minute: 0, title: "Eat your main meal.",      body: "Don't skip. Fuel properly before tonight.")
        await schedule(id: "prenight", hour: 19, minute: 0, title: "Plan your night meal now.", body: "Decide what you're eating tonight before you get hungry.")
    }

    // MARK: - Food Log
    private func scheduleFoodLog(done: Bool) async {
        guard !done else { return }
        await schedule(id: "foodlog_9pm",  hour: 21, minute: 0, title: "Log your food.",        body: "You haven't imported today's calories. Do it now.")
        await schedule(id: "foodlog_10pm", hour: 22, minute: 0, title: "Log your food \u2014 now.", body: "It's 10pm. No more excuses. Open LockIn and log it.")
    }

    // MARK: - Water (9am-9pm every 30 min)
    private func scheduleWater() async {
        let msgs = [
            "Drink a glass of water.",
            "Water check. Have you had enough?",
            "Stay hydrated. Another glass now.",
            "Water. It's free and it works.",
            "Drink water. Keeps appetite in check."
        ]
        var hour = 9; var minute = 0; var idx = 0
        while (hour < 21) || (hour == 21 && minute == 0) {
            await schedule(
                id: "water_\(hour)_\(minute)",
                hour: hour, minute: minute,
                title: msgs[idx % msgs.count],
                body: "Hydration is part of the cut.",
                sound: false
            )
            idx += 1; minute += 30
            if minute >= 60 { minute = 0; hour += 1 }
        }
    }

    // MARK: - Creatine (9am, 2pm, 7pm)
    private func scheduleCreatine() async {
        let slots: [(Int, String)] = [
            (9,  "Take 5g creatine with breakfast."),
            (14, "Take 5g creatine. Don't skip."),
            (19, "Take 5g creatine with dinner.")
        ]
        for (i, (h, body)) in slots.enumerated() {
            await schedule(id: "creatine_\(i)", hour: h, minute: 0, title: "5g creatine.", body: body)
        }
    }

    // MARK: - Nightly Warning
    private func scheduleNightlyWarning() async {
        await schedule(id: "nightly_warning", hour: 21, minute: 0,
                       title: "Don't order food tonight.",
                       body: "You have a plan. Eat what's planned. Nothing else.",
                       category: "NIGHTLY_WARNING")
    }

    private func scheduleBedtime() async {
        await schedule(id: "bedtime", hour: 23, minute: 0,
                       title: "Day is done. Log it.",
                       body: "Open LockIn, mark your checklist, close out the day.")
    }

    // MARK: - Cancel helpers
    func cancelWeighInFollowUps() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["weighin_1", "weighin_2"]
        )
    }

    func cancelFoodLoggingReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["foodlog_9pm", "foodlog_10pm"]
        )
    }

    // MARK: - Core scheduler
    private func schedule(id: String, hour: Int, minute: Int,
                          title: String, body: String,
                          category: String = "", sound: Bool = true) async {
        var comps = DateComponents()
        comps.hour = hour; comps.minute = minute
        let content = UNMutableNotificationContent()
        content.title = title; content.body = body
        content.sound = sound ? .default : nil
        if !category.isEmpty { content.categoryIdentifier = category }
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(req)
    }
}
