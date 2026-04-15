import Foundation
import SwiftData

@Model
final class AdherenceMetric {
    var date: Date
    var complianceScore: Int
    var caloriesLogged: Int
    var proteinLogged: Int
    var carbsLogged: Int
    var fatLogged: Int
    var weighInCompleted: Bool
    var noRestaurant: Bool
    var noDessert: Bool
    var totalPoints: Int

    init(from log: DailyLog) {
        self.date = log.date
        self.complianceScore = log.complianceScore
        self.caloriesLogged = log.actualCalories
        self.proteinLogged = log.actualProtein
        self.carbsLogged = log.actualCarbs
        self.fatLogged = log.actualFat
        self.weighInCompleted = log.checklistItem(for: .morningWeighIn)?.isCompleted ?? false
        self.noRestaurant = log.checklistItem(for: .noRestaurantFood)?.isCompleted ?? false
        self.noDessert = log.checklistItem(for: .noDessert)?.isCompleted ?? false
        self.totalPoints = log.totalPoints
    }
}
