import Foundation
import SwiftData

@Model
final class WorkoutEntry {
    var date: Date
    var type: String
    var durationMinutes: Int
    var caloriesBurned: Int
    var notes: String
    var source: String

    init(date: Date = Date(), type: String = "Workout",
         durationMinutes: Int = 0, caloriesBurned: Int = 0,
         notes: String = "", source: String = "manual") {
        self.date = date
        self.type = type
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.notes = notes
        self.source = source
    }
}
