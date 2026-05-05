import SwiftData
import Foundation

@MainActor
final class TemplateService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createDefaultTemplates() {
        let descriptor = FetchDescriptor<FollowUpTemplate>(predicate: #Predicate { $0.isDefault })
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let defaults: [(String, String, FollowUpChannel, Int)] = [
            ("Post-Meeting Follow-Up", "Great meeting you today! I wanted to follow up on our conversation about [topic]. Let me know if you have any questions.", .email, 1),
            ("Check-In After Proposal", "I wanted to check in on the proposal I sent over. Do you have any questions or need any clarification?", .email, 3),
            ("Quick Text Follow-Up", "Hey! Just wanted to follow up on our conversation. Let me know if you need anything.", .text, 2),
            ("Phone Call Reminder", "Following up on our call. I'll send over the details we discussed. Looking forward to next steps!", .phone, 1),
            ("Monthly Touch Base", "Just checking in! It's been a while since we last connected. How are things going on your end?", .email, 30),
            ("Post-Demo Follow-Up", "Thanks for taking the time to see the demo! I'd love to hear your thoughts and discuss next steps.", .email, 1),
        ]

        for (name, content, channel, days) in defaults {
            let template = FollowUpTemplate(
                name: name,
                content: content,
                channel: channel,
                daysAfterLastContact: days,
                isDefault: true
            )
            modelContext.insert(template)
        }

        try? modelContext.save()
    }

    func createTemplate(name: String, content: String, channel: FollowUpChannel, daysAfterLastContact: Int) -> FollowUpTemplate {
        let template = FollowUpTemplate(
            name: name,
            content: content,
            channel: channel,
            daysAfterLastContact: daysAfterLastContact
        )
        modelContext.insert(template)
        try? modelContext.save()
        return template
    }

    func deleteTemplate(_ template: FollowUpTemplate) {
        modelContext.delete(template)
        try? modelContext.save()
    }
}
