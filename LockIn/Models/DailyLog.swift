import Foundation
import SwiftData

@Model
final class DailyLog {
    var date: Date
    var actualCalories: Int
    var actualProtein: Int
    var actualCarbs: Int
    var actualFat: Int
    var notes: String
    var isWeighedIn: Bool
    var weighInValue: Double
    var isFoodLogged: Bool

    @Relationship(deleteRule: .cascade, inverse: \ChecklistEntry.dailyLog)
    var checklistItems: [ChecklistEntry]

    @Relationship(deleteRule: .cascade, inverse: \MealEvent.dailyLog)
    var mealEvents: [MealEvent]

    init(date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
        self.actualCalories = 0
        self.actualProtein = 0
        self.actualCarbs = 0
        self.actualFat = 0
        self.notes = ""
        self.isWeighedIn = false
        self.weighInValue = 0
        self.isFoodLogged = false
        self.checklistItems = []
        self.mealEvents = []
    }

    var totalPoints: Int {
        checklistItems.filter(\.isCompleted).map { $0.category.points }.reduce(0, +)
    }

    var maxPossiblePoints: Int {
        ComplianceCategory.allCases.map(\.points).reduce(0, +)
    }

    var complianceScore: Int {
        let maxP = maxPossiblePoints
        guard maxP > 0 else { return 0 }
        return min(100, (totalPoints * 100) / maxP)
    }

    func checklistItem(for category: ComplianceCategory) -> ChecklistEntry? {
        checklistItems.first { $0.category == category }
    }

    func ensureChecklistItems() {
        let existing = Set(checklistItems.map(\.category))
        for cat in ComplianceCategory.allCases where !existing.contains(cat) {
            let entry = ChecklistEntry(category: cat)
            entry.dailyLog = self
            checklistItems.append(entry)
        }
    }

    var dateFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }

    var isToday: Bool { Calendar.current.isDateInToday(date) }
}
