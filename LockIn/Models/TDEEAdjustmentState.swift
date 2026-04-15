import Foundation
import SwiftData

@Model
final class TDEEAdjustmentState {
    var estimatedTDEE: Double
    var adaptiveCorrection: Double
    var lastEvaluationDate: Date?
    var weeklyEntriesCount: Int
    var expectedWeeklyLoss: Double

    init(estimatedTDEE: Double = 2175) {
        self.estimatedTDEE = estimatedTDEE
        self.adaptiveCorrection = 0
        self.lastEvaluationDate = nil
        self.weeklyEntriesCount = 0
        self.expectedWeeklyLoss = 0
    }

    var adjustedTDEE: Double { estimatedTDEE + adaptiveCorrection }
}
