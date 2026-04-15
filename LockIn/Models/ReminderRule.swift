import Foundation
import SwiftData

@Model
final class ReminderRule {
    var type: ReminderType
    var hour: Int
    var minute: Int
    var isEnabled: Bool

    init(type: ReminderType, hour: Int? = nil, minute: Int = 0, isEnabled: Bool = true) {
        self.type = type
        self.hour = hour ?? type.defaultHour
        self.minute = minute
        self.isEnabled = isEnabled
    }
}
