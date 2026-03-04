import Foundation

/// User/member identity data shown in Profile and used by personalization.
struct MemberProfile: Codable {
    var name: String
    var chapter: String
    var role: String
    var gradYear: String
    var interests: String
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
