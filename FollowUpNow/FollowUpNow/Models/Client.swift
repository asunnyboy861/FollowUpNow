import SwiftData
import Foundation

@Model
final class Client {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var company: String
    var email: String
    var phone: String
    var notes: String
    var pipelineStage: PipelineStage
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \FollowUp.client)
    var followUps: [FollowUp]

    @Relationship(deleteRule: .cascade, inverse: \Interaction.client)
    var interactions: [Interaction]

    var displayName: String {
        if lastName.isEmpty {
            return firstName
        }
        return "\(firstName) \(lastName)"
    }

    init(firstName: String, lastName: String = "", company: String = "", email: String = "", phone: String = "", notes: String = "") {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.email = email
        self.phone = phone
        self.notes = notes
        self.pipelineStage = .new
        self.createdAt = Date()
        self.updatedAt = Date()
        self.followUps = []
        self.interactions = []
    }
}
