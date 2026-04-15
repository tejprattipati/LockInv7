import Foundation
import SwiftData

@Model
final class MealTemplate {
    var slot: MealSlot
    var name: String
    var targetCalories: Int
    var targetProtein: Int
    var targetCarbs: Int
    var targetFat: Int
    var suggestedFoods: String
    var notes: String
    var isDefault: Bool
    var sortIndex: Int

    init(
        slot: MealSlot,
        name: String,
        targetCalories: Int = 0,
        targetProtein: Int = 0,
        targetCarbs: Int = 0,
        targetFat: Int = 0,
        suggestedFoods: String = "",
        notes: String = "",
        isDefault: Bool = false,
        sortIndex: Int = 0
    ) {
        self.slot = slot
        self.name = name
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFat = targetFat
        self.suggestedFoods = suggestedFoods
        self.notes = notes
        self.isDefault = isDefault
        self.sortIndex = sortIndex
    }
}
