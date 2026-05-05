import SwiftData
import Foundation

@Model
final class FollowUpTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var content: String
    var channel: FollowUpChannel
    var daysAfterLastContact: Int
    var isDefault: Bool
    var createdAt: Date

    init(name: String, content: String, channel: FollowUpChannel = .any, daysAfterLastContact: Int = 3, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.content = content
        self.channel = channel
        self.daysAfterLastContact = daysAfterLastContact
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}
