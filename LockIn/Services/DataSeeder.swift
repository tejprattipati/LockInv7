import Foundation
import SwiftData

final class DataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let desc = FetchDescriptor<UserProfile>()
        guard (try? context.fetchCount(desc)) == 0 else { return }

        // User profile
        let profile = UserProfile(
            name: "Tej", heightInches: 73.5, currentWeightLb: 170.0,
            estimatedBodyFatPct: 0.255, activityLevel: .sedentary,
            dailyCalorieTarget: 1900, dailyProteinTarget: 145
        )
        context.insert(profile)

        // Goal profile
        var dc = DateComponents(); dc.year = 2026; dc.month = 8; dc.day = 8
        let goalDate = Calendar.current.date(from: dc) ?? Date()
        let goal = GoalProfile(
            targetWeightLb: 147.0, targetBodyFatPct: 0.12,
            goalDate: goalDate, startDate: Date(), startWeightLb: 170.0,
            dailyCalorieTarget: 1900, dailyProteinTarget: 145
        )
        goal.cutStartDateForDayCounter = Date()
        goal.reasonsForCutting = [
            "Look noticeably leaner by May 17",
            "Build discipline and stop the ordering spiral",
            "Hit 12% body fat by August 8"
        ]
        context.insert(goal)

        // TDEE state
        context.insert(TDEEAdjustmentState(estimatedTDEE: 2175))

        // Default templates
        let templates: [(MealSlot, String, Int, Int, Int, Int, String)] = [
            (.meal1,          "Eggs & Greek Yogurt",   450, 40, 30, 15, "3 eggs, 1 cup 0% Greek yogurt, fruit"),
            (.meal2,          "Chicken & Rice",         600, 50, 60, 12, "6oz chicken breast, 1 cup rice, vegetables"),
            (.nightMeal,      "Protein + Veggies",      500, 45, 25, 15, "6oz turkey/chicken, large salad, no dressing"),
            (.emergencySnack, "Emergency Snack",        200, 20, 15,  5, "Greek yogurt, cottage cheese, or protein shake")
        ]
        for (i, (slot, name, cal, pro, carb, fat, foods)) in templates.enumerated() {
            let t = MealTemplate(slot: slot, name: name, targetCalories: cal,
                                 targetProtein: pro, targetCarbs: carb, targetFat: fat,
                                 suggestedFoods: foods, isDefault: true, sortIndex: i)
            context.insert(t)
        }

        // Reminder rules
        for type in ReminderType.allCases { context.insert(ReminderRule(type: type)) }

        // MND status
        context.insert(ExternalIntegrationStatus())

        try? context.save()
    }
}
