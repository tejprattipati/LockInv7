import SwiftUI
import SwiftData
import UserNotifications

@main
struct LockInApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var healthKitManager   = HealthKitManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .task { await startup() }
        }
        .modelContainer(for: [
            UserProfile.self,
            GoalProfile.self,
            DailyLog.self,
            ChecklistEntry.self,
            MealEvent.self,
            MealTemplate.self,
            WeightEntry.self,
            WorkoutEntry.self,
            ReminderRule.self,
            TDEEAdjustmentState.self,
            AdherenceMetric.self,
            ExternalIntegrationStatus.self,
            ProgressPhoto.self
        ])
    }

    private func startup() async {
        await notificationManager.checkStatus()
        if notificationManager.isAuthorized {
            await notificationManager.scheduleAll(isWeighedIn: false, isFoodLogged: false)
        }
        if healthKitManager.isAuthorized {
            await healthKitManager.fetchTodayData()
        }
    }
}
