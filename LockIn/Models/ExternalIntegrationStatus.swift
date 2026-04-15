import Foundation
import SwiftData

@Model
final class ExternalIntegrationStatus {
    var service: String
    var deepLinkScheme: String
    var isConfigured: Bool
    var lastOpenedAt: Date?
    var notes: String

    init(service: String = "MyNetDiary",
         deepLinkScheme: String = "mynetdiary://",
         isConfigured: Bool = false) {
        self.service = service
        self.deepLinkScheme = deepLinkScheme
        self.isConfigured = isConfigured
        self.notes = ""
    }
}
