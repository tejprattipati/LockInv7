import Foundation
import SwiftData

@Model
final class ProgressPhoto {
    var date: Date
    var filename: String
    var weightAtTime: Double
    var bodyFatPctAtTime: Double
    var aiAnalysis: String
    var notes: String

    init(date: Date = Date(), filename: String,
         weightAtTime: Double = 0, bodyFatPctAtTime: Double = 0) {
        self.date = date
        self.filename = filename
        self.weightAtTime = weightAtTime
        self.bodyFatPctAtTime = bodyFatPctAtTime
        self.aiAnalysis = ""
        self.notes = ""
    }

    static var storageDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ProgressPhotos", isDirectory: true)
    }

    var imageURL: URL {
        Self.storageDirectory.appendingPathComponent(filename)
    }
}
