import Foundation

struct BodyComposition {
    let weightLb: Double
    let leanBodyMassLb: Double
    let fatMassLb: Double
    let bodyFatPercent: Double
    let bmr: Double
    let tdee: Double
    let calorieBudget: Int
    let dailyDeficit: Double
    let expectedWeeklyLoss: Double
    let daysToGoal: Int
    let projectedGoalDate: Date
    let goalWeightLb: Double
    let recommendedFor1LbWeek: Int
    let recommendedFor15LbWeek: Int

    var explanation: String {
        """
        LBM: \(String(format: "%.1f", leanBodyMassLb)) lb | Fat: \(String(format: "%.1f", fatMassLb)) lb (\(String(format: "%.1f", bodyFatPercent * 100))%)
        BMR: \(Int(bmr)) kcal (Katch-McArdle)
        TDEE: \(Int(tdee)) kcal
        Budget: \(calorieBudget) kcal/day \u2192 \(String(format: "%.2f", expectedWeeklyLoss)) lb/week
        Recommended for 1 lb/week: \(recommendedFor1LbWeek) kcal
        Recommended for 1.5 lb/week: \(recommendedFor15LbWeek) kcal
        """
    }
}

struct CalculationEngine {

    static func bodyComposition(
        profile: UserProfile,
        goal: GoalProfile,
        tdeeState: TDEEAdjustmentState?
    ) -> BodyComposition {
        let weightLb = profile.currentWeightLb
        let lbm = profile.leanBodyMassLb
        let fat = weightLb - lbm
        let bfPct = profile.estimatedBodyFatPercent

        // Katch-McArdle BMR (uses LBM in kg)
        let lbmKg = lbm * 0.453592
        let bmr = 370 + (21.6 * lbmKg)

        // TDEE = BMR x activity multiplier
        let baseTDEE = bmr * profile.activityLevel.multiplier
        let correction = tdeeState?.adaptiveCorrection ?? 0
        let tdee = baseTDEE + correction

        let budget = goal.dailyCalorieTarget
        let deficit = tdee - Double(budget)
        let weeklyLoss = deficit * 7.0 / 3500.0

        let goalWeight = goal.targetWeightLb
        let weightToLose = max(0, weightLb - goalWeight)
        let weeksNeeded = weeklyLoss > 0 ? weightToLose / weeklyLoss : 999
        let daysNeeded = Int(weeksNeeded * 7)
        let projectedDate = Calendar.current.date(byAdding: .day, value: daysNeeded, to: Date()) ?? Date()

        let today = Calendar.current.startOfDay(for: Date())
        let daysToGoal = max(0, Calendar.current.dateComponents([.day], from: today, to: goal.goalDate).day ?? 0)

        return BodyComposition(
            weightLb: weightLb,
            leanBodyMassLb: lbm,
            fatMassLb: fat,
            bodyFatPercent: bfPct,
            bmr: bmr,
            tdee: tdee,
            calorieBudget: budget,
            dailyDeficit: deficit,
            expectedWeeklyLoss: weeklyLoss,
            daysToGoal: daysToGoal,
            projectedGoalDate: projectedDate,
            goalWeightLb: goalWeight,
            recommendedFor1LbWeek: Int(tdee - 500),
            recommendedFor15LbWeek: Int(tdee - 750)
        )
    }

    static func sevenDayAverage(entries: [WeightEntry]) -> Double? {
        let recent = entries.sorted { $0.date > $1.date }.prefix(7)
        guard !recent.isEmpty else { return nil }
        return recent.map(\.weightLb).reduce(0, +) / Double(recent.count)
    }

    static func evaluateAdaptiveTDEE(
        state: TDEEAdjustmentState,
        entries: [WeightEntry],
        budget: Int
    ) {
        guard entries.count >= 10 else { return }
        let sorted = entries.sorted { $0.date < $1.date }
        guard sorted.count >= 14 else { return }

        let firstWeek = Array(sorted.prefix(7))
        let lastWeek  = Array(sorted.suffix(7))
        let avgFirst = firstWeek.map(\.weightLb).reduce(0, +) / 7.0
        let avgLast  = lastWeek.map(\.weightLb).reduce(0, +)  / 7.0

        let daySpan = sorted.last!.date.timeIntervalSince(sorted.first!.date) / 86400
        let weekSpan = max(1.0, daySpan / 7.0)
        let actualLossPerWeek = (avgFirst - avgLast) / weekSpan

        let tdee = state.adjustedTDEE
        let deficit = tdee - Double(budget)
        let expectedLossPerWeek = (deficit * 7) / 3500.0

        let discrepancy = actualLossPerWeek - expectedLossPerWeek
        let rawAdj = discrepancy * 3500.0 / 7.0
        let dampened = rawAdj * 0.40
        state.adaptiveCorrection = max(-75, min(75, state.adaptiveCorrection + dampened))
        state.lastEvaluationDate = Date()
    }

    static func currentStreak(logs: [DailyLog]) -> Int {
        let sorted = logs.sorted { $0.date > $1.date }
        var streak = 0
        for log in sorted {
            if log.complianceScore >= 70 { streak += 1 } else { break }
        }
        return streak
    }

    static func noRestaurantStreak(logs: [DailyLog]) -> Int {
        let sorted = logs.sorted { $0.date > $1.date }
        var streak = 0
        for log in sorted {
            if log.checklistItem(for: .noRestaurantFood)?.isCompleted == true { streak += 1 } else { break }
        }
        return streak
    }
}
