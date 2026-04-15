import Foundation
import SwiftData

@Model
final class ChecklistEntry {
    var category: ComplianceCategory
    var isCompleted: Bool
    var completedAt: Date?
    var notes: String

    var dailyLog: DailyLog?

    init(category: ComplianceCategory) {
        self.category = category
        self.isCompleted = false
        self.completedAt = nil
        self.notes = ""
    }

    func toggle() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}
