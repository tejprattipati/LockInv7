import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var heightInches: Double
    var currentWeightLb: Double
    var leanBodyMassLb: Double
    var activityLevel: ActivityLevel
    var dailyCalorieTarget: Int
    var dailyProteinTarget: Int
    var stepsGoal: Int
    var updatedAt: Date

    init(
        name: String = "Tej",
        heightInches: Double = 73.5,
        currentWeightLb: Double = 170.0,
        estimatedBodyFatPct: Double = 0.255,
        activityLevel: ActivityLevel = .sedentary,
        dailyCalorieTarget: Int = 1900,
        dailyProteinTarget: Int = 145,
        stepsGoal: Int = 8000
    ) {
        self.name = name
        self.heightInches = heightInches
        self.currentWeightLb = currentWeightLb
        self.leanBodyMassLb = currentWeightLb * (1.0 - estimatedBodyFatPct)
        self.activityLevel = activityLevel
        self.dailyCalorieTarget = dailyCalorieTarget
        self.dailyProteinTarget = dailyProteinTarget
        self.stepsGoal = stepsGoal
        self.updatedAt = Date()
    }

    var estimatedBodyFatPercent: Double {
        guard currentWeightLb > 0 else { return 0.25 }
        return max(0.05, (currentWeightLb - leanBodyMassLb) / currentWeightLb)
    }

    var estimatedFatMassLb: Double { currentWeightLb - leanBodyMassLb }

    func updateWeight(_ newWeight: Double) {
        currentWeightLb = newWeight
        updatedAt = Date()
    }

    /// Re-anchors LBM when user manually sets a new BF%
    func reanchorLBM(newBodyFatPct: Double) {
        leanBodyMassLb = currentWeightLb * (1.0 - newBodyFatPct)
        updatedAt = Date()
    }
}
