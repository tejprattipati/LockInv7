import Foundation
import SwiftData

@Model
final class GoalProfile {
    var targetWeightLb: Double
    var targetBodyFatPct: Double
    var goalDate: Date
    var startDate: Date
    var startWeightLb: Double
    var dailyCalorieTarget: Int
    var dailyProteinTarget: Int
    var cutStartDateForDayCounter: Date
    var reasonsForCutting: [String]
    var motivationalText: String
    var redFlagFoods: [String]
    var allowedFoods: [String]

    init(
        targetWeightLb: Double = 147.0,
        targetBodyFatPct: Double = 0.12,
        goalDate: Date = {
            var c = DateComponents()
            c.year = 2026; c.month = 8; c.day = 8
            return Calendar.current.date(from: c) ?? Date()
        }(),
        startDate: Date = Date(),
        startWeightLb: Double = 170.0,
        dailyCalorieTarget: Int = 1900,
        dailyProteinTarget: Int = 145
    ) {
        self.targetWeightLb = targetWeightLb
        self.targetBodyFatPct = targetBodyFatPct
        self.goalDate = goalDate
        self.startDate = startDate
        self.startWeightLb = startWeightLb
        self.dailyCalorieTarget = dailyCalorieTarget
        self.dailyProteinTarget = dailyProteinTarget
        self.cutStartDateForDayCounter = startDate
        self.reasonsForCutting = []
        self.motivationalText = ""
        self.redFlagFoods = ["restaurant food", "dessert", "late-night order"]
        self.allowedFoods = []
    }

    var daysRemaining: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return max(0, Calendar.current.dateComponents([.day], from: today, to: goalDate).day ?? 0)
    }

    /// Days elapsed since the cut started (Day 1 = first day)
    var daysElapsed: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: cutStartDateForDayCounter)
        let diff = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, diff + 1)
    }

    var totalCutDays: Int {
        let start = Calendar.current.startOfDay(for: cutStartDateForDayCounter)
        return max(1, Calendar.current.dateComponents([.day], from: start, to: goalDate).day ?? 1)
    }
}
