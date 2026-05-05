import SwiftData
import Foundation

@Model
final class Interaction {
    @Attribute(.unique) var id: UUID
    var type: FollowUpChannel
    var summary: String
    var date: Date
    var createdAt: Date

    var client: Client?

    init(type: FollowUpChannel, summary: String, date: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.summary = summary
        self.date = date
        self.createdAt = Date()
    }
}
