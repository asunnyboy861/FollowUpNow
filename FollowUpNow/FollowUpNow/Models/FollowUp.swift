import SwiftData
import Foundation

@Model
final class FollowUp {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var dueDate: Date
    var isCompleted: Bool
    var completedAt: Date?
    var reminderOffset: ReminderOffset
    var channel: FollowUpChannel
    var aiGeneratedContent: String?
    var createdAt: Date

    var client: Client?

    init(title: String, notes: String = "", dueDate: Date, channel: FollowUpChannel = .any, reminderOffset: ReminderOffset = .fifteenMinutes) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isCompleted = false
        self.completedAt = nil
        self.channel = channel
        self.reminderOffset = reminderOffset
        self.aiGeneratedContent = nil
        self.createdAt = Date()
    }
}
