import Foundation
import SwiftData

@MainActor
final class AIFollowUpService {

    struct FollowUpSuggestion {
        let subject: String
        let body: String
        let channel: FollowUpChannel
    }

    func generateFollowUp(
        client: Client,
        lastInteraction: Interaction?,
        template: FollowUpTemplate?,
        tone: MessageTone = .friendly
    ) async throws -> FollowUpSuggestion {
        return fallbackSuggestion(client: client, lastInteraction: lastInteraction)
    }

    private func fallbackSuggestion(client: Client, lastInteraction: Interaction?) -> FollowUpSuggestion {
        let body: String
        if let interaction = lastInteraction {
            body = "Hi \(client.firstName), I wanted to follow up on our \(interaction.type.rawValue.lowercased()) from \(interaction.date.formatted(date: .abbreviated, time: .omitted)). Let me know if you have any questions or if there's anything else I can help with."
        } else {
            body = "Hi \(client.firstName), I wanted to reach out and see how things are going. Let me know if there's anything I can help you with."
        }
        return FollowUpSuggestion(subject: "", body: body, channel: .email)
    }
}
