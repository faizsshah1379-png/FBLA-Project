import Foundation

/// User/member identity data shown in Profile and used by personalization.
struct MemberProfile: Codable {
    var firstName: String
    var lastName: String
    var chapter: String
    var role: String
    var gradYear: String
    var interests: String

    var fullName: String {
        let combined = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        return combined.isEmpty ? "Member" : combined
    }

    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case name
        case chapter
        case role
        case gradYear
        case interests
    }

    init(firstName: String, lastName: String, chapter: String, role: String, gradYear: String, interests: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.chapter = chapter
        self.role = role
        self.gradYear = gradYear
        self.interests = interests
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedFirstName = try container.decodeIfPresent(String.self, forKey: .firstName)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let decodedLastName = try container.decodeIfPresent(String.self, forKey: .lastName)?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let firstName = decodedFirstName, !firstName.isEmpty {
            self.firstName = firstName
            self.lastName = decodedLastName ?? ""
        } else {
            let legacyName = try container.decodeIfPresent(String.self, forKey: .name)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let parts = legacyName.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
            self.firstName = parts.first ?? ""
            self.lastName = parts.count > 1 ? parts[1] : ""
        }

        self.chapter = try container.decode(String.self, forKey: .chapter)
        self.role = try container.decode(String.self, forKey: .role)
        self.gradYear = try container.decode(String.self, forKey: .gradYear)
        self.interests = try container.decode(String.self, forKey: .interests)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(chapter, forKey: .chapter)
        try container.encode(role, forKey: .role)
        try container.encode(gradYear, forKey: .gradYear)
        try container.encode(interests, forKey: .interests)
    }
}

/// Single chapter/state event item used by the calendar.
struct EventItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String // Stored as YYYY-MM-DD for predictable parsing.
    let location: String
    let type: String

    /// Converts string date into `Date` for calendar math and comparisons.
    var dateValue: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: date)
    }
}

/// User-created reminder. Codable so we can save/load with UserDefaults.
struct ReminderItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: String

    init(id: UUID = UUID(), title: String, date: String) {
        self.id = id
        self.title = title
        self.date = date
    }
}

/// Resource link data for the Resources tab.
struct ResourceItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let detail: String
    let url: String
}

/// News feed item.
struct AnnouncementItem: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let posted: String
    let body: String
}

/// Social media channel used in Community tab.
struct SocialChannel: Identifiable {
    let id = UUID()
    let platform: String
    let handle: String
    let appURL: String
    let webURL: String
}

/// Saved teammate/peer connection for competition collaboration.
struct TeamConnection: Identifiable, Codable {
    let id: UUID
    let name: String
    let event: String
    let contact: String

    init(id: UUID = UUID(), name: String, event: String, contact: String) {
        self.id = id
        self.name = name
        self.event = event
        self.contact = contact
    }
}
