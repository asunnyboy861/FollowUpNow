import Foundation

enum PipelineStage: String, Codable, CaseIterable {
    case new = "New"
    case contacted = "Contacted"
    case converted = "Converted"

    var color: String {
        switch self {
        case .new: return "blue"
        case .contacted: return "orange"
        case .converted: return "green"
        }
    }

    var systemImage: String {
        switch self {
        case .new: return "person.badge.plus"
        case .contacted: return "phone.connection"
        case .converted: return "checkmark.seal.fill"
        }
    }
}

enum ReminderOffset: Int, Codable, CaseIterable {
    case none = 0
    case fiveMinutes = 5
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case oneDay = 1440

    var displayName: String {
        switch self {
        case .none: return "None"
        case .fiveMinutes: return "5 min before"
        case .fifteenMinutes: return "15 min before"
        case .thirtyMinutes: return "30 min before"
        case .oneHour: return "1 hour before"
        case .oneDay: return "1 day before"
        }
    }
}

enum FollowUpChannel: String, Codable, CaseIterable {
    case any = "Any"
    case phone = "Phone"
    case text = "Text"
    case email = "Email"
    case inPerson = "In Person"

    var systemImage: String {
        switch self {
        case .any: return "arrow.triangle.2.circlepath"
        case .phone: return "phone.fill"
        case .text: return "message.fill"
        case .email: return "envelope.fill"
        case .inPerson: return "person.2.fill"
        }
    }
}

enum DateFilter: String, CaseIterable {
    case today = "Today"
    case overdue = "Overdue"
    case thisWeek = "This Week"
    case all = "All"
}

enum MessageTone: String, CaseIterable {
    case friendly = "Friendly and warm"
    case professional = "Professional and formal"
    case casual = "Casual and relaxed"
    case urgent = "Urgent and direct"
}
