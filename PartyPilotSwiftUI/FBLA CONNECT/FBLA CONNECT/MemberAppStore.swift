import Foundation
import Combine

/// Central state manager for the whole app.
///
/// Why this exists:
/// - Holds all mutable UI state in one place.
/// - Exposes computed data (filtered news, chapter events, validation).
/// - Handles persistence (profile, reminders, connections) with UserDefaults + Firestore.
@MainActor
final class MemberAppStore: ObservableObject {
    // MARK: - Editable Member Data

    private static let defaultProfile = MemberProfile(
        firstName: "Jordan",
        lastName: "Lee",
        chapter: "Franklin High School",
        state: "New Jersey",
        role: "Chapter VP",
        gradYear: "2027",
        interests: "Event Planning, Finance, Leadership"
    )

    @Published var profile = defaultProfile

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

    let defaultSocialChannels: [SocialChannel] = [
        .init(platform: "Instagram", handle: "@njfbla", appURL: "instagram://user?username=njfbla", webURL: "https://www.instagram.com/njfbla"),
        .init(platform: "YouTube", handle: "@njfblaofficial", appURL: "youtube://www.youtube.com/@njfblaofficial", webURL: "https://www.youtube.com/@njfblaofficial"),
        .init(platform: "LinkedIn", handle: "linkedin.com/in/njfbla", appURL: "https://www.linkedin.com/in/njfbla", webURL: "https://www.linkedin.com/in/njfbla"),
        .init(platform: "X", handle: "@njfbla", appURL: "twitter://user?screen_name=njfbla", webURL: "https://x.com/njfbla")
    ]

    let newYorkSocialChannels: [SocialChannel] = [
        .init(platform: "Instagram", handle: "@newyorkfbla", appURL: "instagram://user?username=newyorkfbla", webURL: "https://www.instagram.com/newyorkfbla"),
        .init(platform: "YouTube", handle: "@newyorkfbla1931", appURL: "youtube://www.youtube.com/@newyorkfbla1931", webURL: "https://www.youtube.com/@newyorkfbla1931"),
        .init(platform: "LinkedIn", handle: "linkedin.com/in/new-york-fbla-459451125", appURL: "https://www.linkedin.com/in/new-york-fbla-459451125", webURL: "https://www.linkedin.com/in/new-york-fbla-459451125"),
        .init(platform: "X", handle: "@NewYorkFBLA", appURL: "twitter://user?screen_name=NewYorkFBLA", webURL: "https://x.com/NewYorkFBLA")
    ]

    private let newYorkSocialOverrideEmails: Set<String> = [
        "sahibvassan2000@gmail.com",
        "sahilvassan21@gmail.com"
    ]

    // MARK: - Persistence Keys

    private let remindersKey = "fbla.member.reminders.v2"
    private let profileCacheKeyPrefix = "fbla.member.profile.v3"
    private let legacyProfileKey = "fbla.member.profile.v2"
    private let connectionsKey = "fbla.member.connections.v1"
    private let firestoreCollection = "memberProfiles"

    private var activeUserID: String?
    private var activeIDToken: String?
    private var activeUserEmail: String?

    // MARK: - Lifecycle

    init() {
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

    private func canonicalState(from input: String) -> String? {
        let normalized = input
            .lowercased()
            .replacingOccurrences(of: ".", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else { return nil }

        switch normalized {
        case "new jersey", "newjersey", "nj":
            return "New Jersey"
        case "new york", "newyork", "ny":
            return "New York"
        case "pennsylvania", "pa":
            return "Pennsylvania"
        case "texas", "tx":
            return "Texas"
        case "california", "ca":
            return "California"
        case "florida", "fl":
            return "Florida"
        case "georgia", "ga":
            return "Georgia"
        case "north carolina", "northcarolina", "nc":
            return "North Carolina"
        default:
            return nil
        }
    }

    private func inferredStateFromChapter() -> String {
        let chapter = profile.chapter.lowercased()
        let mappings: [(String, String)] = [
            ("new jersey", "New Jersey"),
            ("nj", "New Jersey"),
            ("franklin high school", "New Jersey"),
            ("fhs", "New Jersey"),
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

    private var chapterLabelForContent: String {
        let trimmed = profile.chapter.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Your Chapter" : trimmed
    }

    /// Uses explicit profile state when available, then falls back to chapter inference.
    var detectedState: String {
        canonicalState(from: profile.state) ?? inferredStateFromChapter()
    }

    private func stateSlug(_ state: String) -> String {
        let slug = state
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "", options: .regularExpression)
        return slug.isEmpty ? "fbla" : slug
    }

    private func normalizedEmail(_ email: String?) -> String? {
        guard let email else { return nil }
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized.isEmpty ? nil : normalized
    }

    /// State-based social channels (chapter context is still shown in UI labels).
    var socialChannels: [SocialChannel] {
        if let activeUserEmail,
           newYorkSocialOverrideEmails.contains(activeUserEmail) {
            return newYorkSocialChannels
        }

        let state = detectedState
        guard state != "National", state != "New Jersey" else { return defaultSocialChannels }

        let slug = stateSlug(state)
        let instagramHandle = "\(slug)fbla"
        let xHandle = "\(slug)FBLA"

        return [
            .init(platform: "Instagram", handle: "@\(instagramHandle)", appURL: "instagram://user?username=\(instagramHandle)", webURL: "https://www.instagram.com/\(instagramHandle)"),
            .init(platform: "YouTube", handle: "\(state) FBLA", appURL: "youtube://www.youtube.com/@\(slug)fbla", webURL: "https://www.youtube.com/results?search_query=\(state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? state)+FBLA"),
            .init(platform: "LinkedIn", handle: "\(state) FBLA", appURL: "linkedin://company", webURL: "https://www.linkedin.com/search/results/all/?keywords=\(state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? state)%20FBLA"),
            .init(platform: "X", handle: "@\(xHandle)", appURL: "twitter://user?screen_name=\(xHandle)", webURL: "https://x.com/\(xHandle)")
        ]
    }

    /// Adds state-priority news cards to the top of the feed.
    var personalizedAnnouncements: [AnnouncementItem] {
        let state = detectedState
        let chapter = chapterLabelForContent
        let stateFeed: [AnnouncementItem] = [
            .init(
                title: "\(state) FBLA state competition schedule update",
                source: "\(state) FBLA",
                posted: "Today",
                body: "\(chapter) members: check reporting times, event room locations, and final deadlines for the \(state) conference.",
                url: "https://www.fbla.org/conferences/"
            ),
            .init(
                title: "\(state) chapter advisor bulletin",
                source: "\(state) FBLA",
                posted: "Today",
                body: "State guidance and chapter action items were updated for \(chapter).",
                url: "https://www.fbla.org/adviser-resource-center/"
            )
        ]

        return stateFeed + announcements
    }

    /// Event list personalized to detected state while keeping chapter references.
    /// For NJ, includes requested SLC dates March 9-11.
    var chapterEvents: [EventItem] {
        let chapter = chapterLabelForContent
        if detectedState == "New Jersey" {
            return [
                .init(title: "NJ FBLA SLC - Day 1 (Opening Session)", date: "2026-03-09", location: "Harrah's Waterfront Conference Center", type: "Competition"),
                .init(title: "NJ FBLA SLC - Day 2 (Testing & Presentations)", date: "2026-03-10", location: "Harrah's Waterfront Conference Center", type: "Competition"),
                .init(title: "NJ FBLA SLC - Day 3 (Finals & Awards)", date: "2026-03-11", location: "Harrah's Waterfront Conference Center", type: "Competition"),
                .init(title: "\(chapter) FBLA Chapter Debrief Meeting", date: "2026-03-12", location: "\(chapter) Room 214", type: "Meeting"),
                .init(title: "\(chapter) Competitive Event Practice", date: "2026-03-17", location: "\(chapter) Media Center", type: "Practice"),
                .init(title: "NJ FBLA Leadership Workshop", date: "2026-04-07", location: "Rutgers Business Center", type: "Workshop"),
                .init(title: "\(chapter) Officer Elections", date: "2026-04-18", location: "\(chapter) Auditorium", type: "Leadership")
            ]
        }
        if detectedState == "National" {
            return defaultEvents
        }

        return [
            .init(title: "\(chapter) Chapter Meeting", date: "2026-03-08", location: "Business Lab 204", type: "Meeting"),
            .init(title: "\(detectedState) FBLA Registration Deadline", date: "2026-03-12", location: "\(detectedState) FBLA Portal", type: "Deadline"),
            .init(title: "\(chapter) Resume Workshop", date: "2026-03-16", location: "Library", type: "Workshop"),
            .init(title: "\(chapter) Mock Interview Night", date: "2026-03-19", location: "Auditorium", type: "Practice"),
            .init(title: "\(chapter) Community Service Drive", date: "2026-04-05", location: "Downtown Hub", type: "Service"),
            .init(title: "\(chapter) Officer Elections", date: "2026-04-17", location: "Room 110", type: "Leadership")
        ]
    }

    /// Text exported by ShareLink in Community tab.
    var memberShareText: String {
        """
        FBLA Member Connection Card
        Name: \(profile.fullName)
        Chapter: \(profile.chapter)
        State: \(detectedState)
        Role: \(profile.role)
        Graduation Year: \(profile.gradYear)
        Interests: \(profile.interests)
        """
    }

    // MARK: - Public Mutations

    func saveProfile() {
        persistProfileCache(profile, for: activeUserID)

        guard let userID = activeUserID,
              let idToken = activeIDToken else { return }

        let currentProfile = profile
        Task {
            do {
                try await saveProfileToFirestore(currentProfile, userID: userID, idToken: idToken)
            } catch {
                print("Member profile save failed: \(error.localizedDescription)")
            }
        }
    }

    func bindAuthenticatedUser(userID: String, idToken: String, email: String?) async {
        let normalizedUserID = userID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedUserID.isEmpty else { return }

        activeUserID = normalizedUserID
        activeIDToken = idToken
        activeUserEmail = normalizedEmail(email)

        if let cached = loadCachedProfile(for: normalizedUserID) {
            profile = cached
        } else {
            profile = Self.defaultProfile
        }

        do {
            let remoteProfile = try await fetchProfileFromFirestore(userID: normalizedUserID, idToken: idToken)
            guard activeUserID == normalizedUserID else { return }

            if let remoteProfile {
                profile = remoteProfile
                persistProfileCache(remoteProfile, for: normalizedUserID)
                return
            }

            if let cached = loadCachedProfile(for: normalizedUserID) {
                profile = cached
                try await saveProfileToFirestore(cached, userID: normalizedUserID, idToken: idToken)
                return
            }

            if let legacy = loadLegacyProfile() {
                profile = legacy
                persistProfileCache(legacy, for: normalizedUserID)
                try await saveProfileToFirestore(legacy, userID: normalizedUserID, idToken: idToken)
                clearLegacyProfile()
                return
            }

            profile = Self.defaultProfile
            persistProfileCache(profile, for: normalizedUserID)
            try await saveProfileToFirestore(profile, userID: normalizedUserID, idToken: idToken)
        } catch {
            guard activeUserID == normalizedUserID else { return }

            if let cached = loadCachedProfile(for: normalizedUserID) {
                profile = cached
            } else if let legacy = loadLegacyProfile() {
                profile = legacy
            } else {
                profile = Self.defaultProfile
            }

            print("Member profile sync failed: \(error.localizedDescription)")
        }
    }

    func clearAuthenticatedUser() {
        activeUserID = nil
        activeIDToken = nil
        activeUserEmail = nil
        profile = Self.defaultProfile
    }

    func updateProfileFromSignup(
        firstName: String,
        lastName: String,
        chapter: String,
        state: String,
        userID: String?,
        idToken: String?,
        email: String?
    ) async {
        profile.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.chapter = chapter.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.state = state.trimmingCharacters(in: .whitespacesAndNewlines)

        if let userID = userID?.trimmingCharacters(in: .whitespacesAndNewlines),
           !userID.isEmpty,
           let idToken,
           !idToken.isEmpty {
            activeUserID = userID
            activeIDToken = idToken
        }
        activeUserEmail = normalizedEmail(email) ?? activeUserEmail

        persistProfileCache(profile, for: activeUserID)

        guard let boundUserID = activeUserID,
              let boundIDToken = activeIDToken else { return }

        do {
            try await saveProfileToFirestore(profile, userID: boundUserID, idToken: boundIDToken)
        } catch {
            print("Member profile signup save failed: \(error.localizedDescription)")
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

    private func profileCacheKey(for userID: String) -> String {
        "\(profileCacheKeyPrefix).\(userID)"
    }

    private func persistProfileCache(_ profile: MemberProfile, for userID: String?) {
        guard let userID = userID?.trimmingCharacters(in: .whitespacesAndNewlines),
              !userID.isEmpty,
              let encoded = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(encoded, forKey: profileCacheKey(for: userID))
    }

    private func loadCachedProfile(for userID: String) -> MemberProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileCacheKey(for: userID)),
              let decoded = try? JSONDecoder().decode(MemberProfile.self, from: data) else { return nil }
        return decoded
    }

    private func loadLegacyProfile() -> MemberProfile? {
        guard let data = UserDefaults.standard.data(forKey: legacyProfileKey),
              let decoded = try? JSONDecoder().decode(MemberProfile.self, from: data) else { return nil }
        return decoded
    }

    private func clearLegacyProfile() {
        UserDefaults.standard.removeObject(forKey: legacyProfileKey)
    }

    private func firestoreProjectID() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
              let projectID = plist["PROJECT_ID"] as? String else {
            return nil
        }
        let trimmed = projectID.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func firestoreDocumentURL(for userID: String) -> URL? {
        guard let projectID = firestoreProjectID() else { return nil }
        guard let escapedUserID = userID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return nil }
        return URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/\(firestoreCollection)/\(escapedUserID)")
    }

    private func extractFirestoreErrorMessage(from data: Data) -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let errorBody = json["error"] as? [String: Any] else {
            return "Firestore request failed."
        }

        if let message = errorBody["message"] as? String,
           !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return message
        }

        return "Firestore request failed."
    }

    private func firestoreFields(from profile: MemberProfile) -> [String: Any] {
        [
            "firstName": ["stringValue": profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)],
            "lastName": ["stringValue": profile.lastName.trimmingCharacters(in: .whitespacesAndNewlines)],
            "chapter": ["stringValue": profile.chapter.trimmingCharacters(in: .whitespacesAndNewlines)],
            "state": ["stringValue": profile.state.trimmingCharacters(in: .whitespacesAndNewlines)],
            "role": ["stringValue": profile.role.trimmingCharacters(in: .whitespacesAndNewlines)],
            "gradYear": ["stringValue": profile.gradYear.trimmingCharacters(in: .whitespacesAndNewlines)],
            "interests": ["stringValue": profile.interests.trimmingCharacters(in: .whitespacesAndNewlines)]
        ]
    }

    private func makeProfile(from firestoreDocument: FirestoreProfileDocument) -> MemberProfile? {
        guard let fields = firestoreDocument.fields else { return nil }
        let fallback = Self.defaultProfile

        func value(_ key: String, fallback defaultValue: String) -> String {
            fields[key]?.stringValue ?? defaultValue
        }

        return MemberProfile(
            firstName: value("firstName", fallback: fallback.firstName),
            lastName: value("lastName", fallback: fallback.lastName),
            chapter: value("chapter", fallback: fallback.chapter),
            state: value("state", fallback: fallback.state),
            role: value("role", fallback: fallback.role),
            gradYear: value("gradYear", fallback: fallback.gradYear),
            interests: value("interests", fallback: fallback.interests)
        )
    }

    private func fetchProfileFromFirestore(userID: String, idToken: String) async throws -> MemberProfile? {
        guard let url = firestoreDocumentURL(for: userID) else {
            throw NSError(domain: "MemberProfile", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase project configuration for profile sync."])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "MemberProfile", code: 2, userInfo: [NSLocalizedDescriptionKey: "No response from Firestore."])
        }

        switch httpResponse.statusCode {
        case 200...299:
            guard let decoded = try? JSONDecoder().decode(FirestoreProfileDocument.self, from: data) else {
                throw NSError(domain: "MemberProfile", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid Firestore profile response."])
            }
            return makeProfile(from: decoded)
        case 404:
            return nil
        default:
            let message = extractFirestoreErrorMessage(from: data)
            throw NSError(domain: "MemberProfile", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
    }

    private func saveProfileToFirestore(_ profile: MemberProfile, userID: String, idToken: String) async throws {
        guard let url = firestoreDocumentURL(for: userID) else {
            throw NSError(domain: "MemberProfile", code: 4, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase project configuration for profile sync."])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["fields": firestoreFields(from: profile)])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "MemberProfile", code: 5, userInfo: [NSLocalizedDescriptionKey: "No response from Firestore."])
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = extractFirestoreErrorMessage(from: data)
            throw NSError(domain: "MemberProfile", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
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

private struct FirestoreProfileDocument: Decodable {
    let fields: [String: FirestoreProfileField]?
}

private struct FirestoreProfileField: Decodable {
    let stringValue: String?
}
