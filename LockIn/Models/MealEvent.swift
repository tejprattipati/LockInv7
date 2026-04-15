import Foundation
import SwiftData

@Model
final class MealEvent {
    var slot: MealSlot
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var foods: String
    var notes: String
    var isCompleted: Bool
    var completedAt: Date?
    var loggedInMND: Bool

    var dailyLog: DailyLog?

    init(slot: MealSlot, name: String = "", calories: Int = 0,
         protein: Int = 0, carbs: Int = 0, fat: Int = 0) {
        self.slot = slot
        self.name = name.isEmpty ? slot.displayName : name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.foods = ""
        self.notes = ""
        self.isCompleted = false
        self.completedAt = nil
        self.loggedInMND = false
    }

    static func from(template: MealTemplate) -> MealEvent {
        let e = MealEvent(
            slot: template.slot,
            name: template.name,
            calories: template.targetCalories,
            protein: template.targetProtein,
            carbs: template.targetCarbs,
            fat: template.targetFat
        )
        e.foods = template.suggestedFoods
        e.notes = template.notes
        return e
    }
}
