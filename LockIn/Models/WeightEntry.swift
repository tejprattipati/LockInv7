import Foundation
import SwiftData

@Model
final class WeightEntry {
    var date: Date
    var weightLb: Double
    var bodyFatPercent: Double?
    var source: String

    init(date: Date = Date(), weightLb: Double,
         bodyFatPercent: Double? = nil, source: String = "manual") {
        self.date = date
        self.weightLb = weightLb
        self.bodyFatPercent = bodyFatPercent
        self.source = source
    }
}
