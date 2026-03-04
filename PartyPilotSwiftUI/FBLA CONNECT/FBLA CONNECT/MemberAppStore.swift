import Foundation
import Combine

/// Central state manager for the whole app.
///
/// Why this exists:
/// - Holds all mutable UI state in one place.
/// - Exposes computed data (filtered news, chapter events, validation).
/// - Handles persistence (profile, reminders, connections) with UserDefaults.
@MainActor
final class MemberAppStore: ObservableObject {
    // MARK: - Editable Member Data

    /// Default sample profile requested by user.
    @Published var profile = MemberProfile(
        firstName: "Jordan",
        lastName: "Lee",
        chapter: "Franklin High School",
        role: "Chapter VP",
        gradYear: "2027",
        interests: "Event Planning, Finance, Leadership"
    )

    // MARK: - Reminders

    @Published var reminders: [ReminderItem] = []
    @Published var reminderTitle = ""
    @Published var reminderDate = ""

    // MARK: - Search/Filter Inputs

    @Published var resourceFilter = ""
    @Published var newsFilter = ""

    // MARK: - Team Connect Form + Saved Data

    @Published var connections: [TeamConnection] = []
    @Published var connectionName = ""
    @Published var connectionEvent = ""
    @Published var connectionContact = ""

    // MARK: - Static Source Data

    /// Default fallback events for non-NJ chapters.
    let defaultEvents: [EventItem] = [
        .init(title: "Chapter Meeting", date: "2026-03-08", location: "Business Lab 204", type: "Meeting"),
        .init(title: "District Competition Registration Due", date: "2026-03-12", location: "FBLA Portal", type: "Deadline"),
        .init(title: "Resume Workshop", date: "2026-03-16", location: "Library", type: "Workshop"),
        .init(title: "Mock Interview Night", date: "2026-03-19", location: "Auditorium", type: "Practice"),
        .init(title: "Community Service Drive", date: "2026-04-05", location: "Downtown Hub", type: "Service"),
        .init(title: "Officer Elections", date: "2026-04-17", location: "Room 110", type: "Leadership")
    ]

    let resources: [ResourceItem] = [
        .init(name: "FBLA National Website", category: "Official", detail: "Competition information, updates, and program details", url: "https://www.fbla.org"),
        .init(name: "Competitive Events Guidelines", category: "Document", detail: "Rules and scoring guidelines for all events", url: "https://www.fbla.org/competitive-events/"),
        .init(name: "Officer Handbook", category: "Document", detail: "Leadership duties, planning templates, and chapter operations", url: "https://www.fbla.org"),
        .init(name: "Dress Code & Presentation Standards", category: "Document", detail: "Professional standards for conferences and presentations", url: "https://www.fbla.org"),
        .init(name: "Resume and Portfolio Templates", category: "Template", detail: "Career-ready resume and portfolio starter pack", url: "https://www.fbla.org"),
        .init(name: "Chapter Planning Toolkit", category: "Toolkit", detail: "Meeting agenda templates and project planning checklists", url: "https://www.fbla.org")
    ]

    let announcements: [AnnouncementItem] = [
        .init(
            title: "SLC registration deadline moved to March 14",
            source: "State FBLA",
            posted: "2h ago",
            body: "All chapters must finalize competitor rosters by Friday at 5:00 PM.",
            url: "https://www.fbla.org/conferences/"
        ),
        .init(
            title: "New objective test prep packet released",
            source: "National FBLA",
            posted: "6h ago",
            body: "Updated practice questions are available in the resources portal.",
            url: "https://www.fbla.org/competitive-events/"
        ),
        .init(
            title: "Scholarship applications now open",
            source: "National FBLA",
            posted: "1d ago",
            body: "Member scholarship application window closes April 10, 2026.",
            url: "https://www.fbla.org/scholarships/"
        ),
        .init(
            title: "Community service challenge posted",
            source: "Chapter Advisors",
            posted: "2d ago",
            body: "Top three chapters by service hours receive recognition at SLC.",
            url: "https://www.fbla.org/programs/"
        ),
        .init(
            title: "NLC travel webinar scheduled",
            source: "Region Leadership",
            posted: "3d ago",
            body: "Join the webinar for travel, packing, and presentation logistics.",
            url: "https://www.fbla.org/conferences/nlc/"
        ),
        .init(
            title: "Monthly chapter newsletter published",
            source: "Northview HS FBLA",
            posted: "4d ago",
            body: "Includes upcoming events, member spotlight, and officer updates.",
            url: "https://www.fbla.org/news/"
        )
    ]

    let socialChannels: [SocialChannel] = [
        .init(platform: "Instagram", handle: "@northview_fbla", appURL: "instagram://user?username=northview_fbla", webURL: "https://www.instagram.com/northview_fbla"),
        .init(platform: "YouTube", handle: "Northview FBLA", appURL: "youtube://www.youtube.com/@northviewfbla", webURL: "https://www.youtube.com"),
        .init(platform: "LinkedIn", handle: "Northview FBLA Alumni", appURL: "linkedin://company", webURL: "https://www.linkedin.com"),
        .init(platform: "X", handle: "@NorthviewFBLA", appURL: "twitter://user?screen_name=NorthviewFBLA", webURL: "https://x.com/NorthviewFBLA")
    ]

    // MARK: - Persistence Keys

    private let remindersKey = "fbla.member.reminders.v2"
    private let profileKey = "fbla.member.profile.v2"
    private let connectionsKey = "fbla.member.connections.v1"

    // MARK: - Lifecycle

    init() {
        loadProfile()
        loadReminders()
        loadConnections()
    }

    // MARK: - Validation

    /// Validates reminder title and date.
    /// Includes syntactic validation (format) and semantic validation (not in the past).
    var reminderValidationMessage: String? {
        let titleTrim = reminderTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if titleTrim.count < 4 { return "Title must be at least 4 characters." }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let parsed = formatter.date(from: reminderDate) else {
            return "Date must be in YYYY-MM-DD format."
        }

        let today = Calendar.current.startOfDay(for: Date())
        if parsed < today { return "Date must be today or in the future." }

        return nil
    }

    /// Validates Team Connect form inputs.
    var connectionValidationMessage: String? {
        let name = connectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        let event = connectionEvent.trimmingCharacters(in: .whitespacesAndNewlines)
        let contact = connectionContact.trimmingCharacters(in: .whitespacesAndNewlines)

        if name.count < 3 { return "Teammate name must be at least 3 characters." }
        if event.count < 4 { return "Competition event must be at least 4 characters." }
        if contact.count < 4 { return "Contact must be at least 4 characters." }

        // Accept either email or phone number.
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", "^[A-Z0-9._%+\\-]+@[A-Z0-9.\\-]+\\.[A-Z]{2,}$")
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", "^\\+?[0-9 ()\\-]{7,20}$")
        let isEmail = emailPredicate.evaluate(with: contact)
        let isPhone = phonePredicate.evaluate(with: contact)
        if !isEmail && !isPhone {
            return "Contact must be a valid email or phone number."
        }

        return nil
    }

    // MARK: - Computed Data for UI

    /// Resource list filtered by search query.
    var filteredResources: [ResourceItem] {
        let q = resourceFilter.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return resources }
        return resources.filter { $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q) }
    }

    /// News feed filtered by query, after personalization.
    var filteredAnnouncements: [AnnouncementItem] {
        let q = newsFilter.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let source = personalizedAnnouncements
        guard !q.isEmpty else { return source }
        return source.filter { $0.title.lowercased().contains(q) || $0.source.lowercased().contains(q) || $0.body.lowercased().contains(q) }
    }

    /// Infers likely state from chapter name text.
    /// Example: "Franklin High School" => "New Jersey".
    var detectedState: String {
        let chapter = profile.chapter.lowercased()
        let mappings: [(String, String)] = [
            ("new jersey", "New Jersey"),
            ("nj", "New Jersey"),
            ("franklin high school", "New Jersey"),
            ("texas", "Texas"),
            ("tx", "Texas"),
            ("california", "California"),
            ("ca", "California"),
            ("florida", "Florida"),
            ("fl", "Florida"),
            ("georgia", "Georgia"),
            ("ga", "Georgia"),
            ("north carolina", "North Carolina"),
            ("nc", "North Carolina"),
            ("new york", "New York"),
            ("ny", "New York"),
            ("pennsylvania", "Pennsylvania"),
            ("pa", "Pennsylvania")
        ]

        for (key, state) in mappings where chapter.contains(key) {
            return state
        }

        return "National"
    }

    /// Adds state-priority news cards to the top of the feed.
    var personalizedAnnouncements: [AnnouncementItem] {
        let state = detectedState
        let stateFeed: [AnnouncementItem] = [
            .init(
                title: "\(state) FBLA state competition schedule update",
                source: "\(state) FBLA",
                posted: "Today",
                body: "Check reporting times, event room locations, and final deadlines for the \(state) conference.",
                url: "https://www.fbla.org/conferences/"
            ),
            .init(
                title: "\(state) chapter advisor bulletin",
                source: "\(state) FBLA",
                posted: "Today",
                body: "Updated guidance posted for competitive event submissions, dress code reminders, and presentation check-in steps.",
                url: "https://www.fbla.org/adviser-resource-center/"
            )
        ]

        return stateFeed + announcements
    }

    /// Event list personalized to detected state.
    /// For NJ, includes requested SLC dates March 9-11.
    var chapterEvents: [EventItem] {
        if detectedState == "New Jersey" {
            return [
                .init(title: "NJ FBLA SLC - Day 1 (Opening Session)", date: "2026-03-09", location: "Harrah's Waterfront Conference Center", type: "Competition"),
                .init(title: "NJ FBLA SLC - Day 2 (Testing & Presentations)", date: "2026-03-10", location: "Harrah's Waterfront Conference Center", type: "Competition"),
                .init(title: "NJ FBLA SLC - Day 3 (Finals & Awards)", date: "2026-03-11", location: "Harrah's Waterfront Conference Center", type: "Competition"),
                .init(title: "Franklin FBLA Chapter Debrief Meeting", date: "2026-03-12", location: "Franklin HS Room 214", type: "Meeting"),
                .init(title: "NJ FBLA SLC Registration Deadline", date: "2026-03-07", location: "NJ FBLA Portal", type: "Deadline"),
                .init(title: "Franklin Competitive Event Practice", date: "2026-03-17", location: "Franklin HS Media Center", type: "Practice"),
                .init(title: "NJ FBLA Leadership Workshop", date: "2026-04-07", location: "Rutgers Business Center", type: "Workshop"),
                .init(title: "Franklin HS Officer Elections", date: "2026-04-18", location: "Franklin HS Auditorium", type: "Leadership")
            ]
        }
        return defaultEvents
    }

    /// Text exported by ShareLink in Community tab.
    var memberShareText: String {
        """
        FBLA Member Connection Card
        Name: \(profile.fullName)
        Chapter: \(profile.chapter)
        Role: \(profile.role)
        Graduation Year: \(profile.gradYear)
        Interests: \(profile.interests)
        """
    }

    // MARK: - Public Mutations

    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }

    func addReminder() {
        guard reminderValidationMessage == nil else { return }
        reminders.insert(ReminderItem(title: reminderTitle, date: reminderDate), at: 0)
        reminderTitle = ""
        reminderDate = ""
        persistReminders()
    }

    func deleteReminder(_ id: UUID) {
        reminders.removeAll { $0.id == id }
        persistReminders()
    }

    func addConnection() {
        guard connectionValidationMessage == nil else { return }
        connections.insert(
            TeamConnection(
                name: connectionName.trimmingCharacters(in: .whitespacesAndNewlines),
                event: connectionEvent.trimmingCharacters(in: .whitespacesAndNewlines),
                contact: connectionContact.trimmingCharacters(in: .whitespacesAndNewlines)
            ),
            at: 0
        )
        connectionName = ""
        connectionEvent = ""
        connectionContact = ""
        persistConnections()
    }

    func deleteConnection(_ id: UUID) {
        connections.removeAll { $0.id == id }
        persistConnections()
    }

    // MARK: - Persistence Helpers

    private func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let decoded = try? JSONDecoder().decode(MemberProfile.self, from: data) else { return }
        profile = decoded
    }

    private func loadReminders() {
        guard let data = UserDefaults.standard.data(forKey: remindersKey),
              let decoded = try? JSONDecoder().decode([ReminderItem].self, from: data) else {
            // Seed reminders for first app run.
            reminders = [
                .init(title: "Submit district event picks", date: "2026-03-10"),
                .init(title: "Upload presentation deck", date: "2026-03-18"),
                .init(title: "Confirm travel consent form", date: "2026-03-22")
            ]
            return
        }
        reminders = decoded
    }

    private func persistReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: remindersKey)
        }
    }

    private func loadConnections() {
        guard let data = UserDefaults.standard.data(forKey: connectionsKey),
              let decoded = try? JSONDecoder().decode([TeamConnection].self, from: data) else {
            // Seed teammate examples for demo usability.
            connections = [
                .init(name: "Maya Chen", event: "Mobile Application Development", contact: "maya.chen@school.edu"),
                .init(name: "Noah Patel", event: "Intro to Financial Math", contact: "+1 (555) 222-0189"),
                .init(name: "Ari Thompson", event: "Social Media Strategies", contact: "ari.thompson@school.edu")
            ]
            return
        }
        connections = decoded
    }

    private func persistConnections() {
        if let encoded = try? JSONEncoder().encode(connections) {
            UserDefaults.standard.set(encoded, forKey: connectionsKey)
        }
    }
}
