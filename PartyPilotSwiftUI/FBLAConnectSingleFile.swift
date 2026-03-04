import SwiftUI

@main
struct FBLAConnectApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    private var showChapterOnboarding: Binding<Bool> {
        Binding(get: { store.selectedChapter == nil }, set: { _ in })
    }

    var body: some View {
        ZStack {
            FBLATheme.page.ignoresSafeArea()

            TabView {
                HomeTabView().tabItem { Label("Home", systemImage: "house.fill") }
                ProfileTabView().tabItem { Label("Profile", systemImage: "person.circle.fill") }
                TimelineTabView().tabItem { Label("Timeline", systemImage: "calendar") }
                ResourcesTabView().tabItem { Label("Resources", systemImage: "folder.fill") }
                NewsTabView().tabItem { Label("News", systemImage: "newspaper.fill") }
                CommunityTabView().tabItem { Label("Community", systemImage: "person.3.fill") }
            }
            .tint(FBLATheme.brightBlue)
        }
        .fullScreenCover(isPresented: showChapterOnboarding) {
            ChapterOnboardingView().environmentObject(store)
        }
    }
}

// MARK: - Theme

enum FBLATheme {
    static let navy = Color(red: 11/255, green: 19/255, blue: 43/255)
    static let royal = Color(red: 28/255, green: 37/255, blue: 65/255)
    static let brightBlue = Color(red: 58/255, green: 134/255, blue: 255/255)
    static let gold = Color(red: 1.0, green: 209/255, blue: 102/255)
    static let page = Color(red: 244/255, green: 248/255, blue: 1.0)
    static let card = Color.white
    static let text = Color(red: 15/255, green: 23/255, blue: 42/255)
    static let muted = Color(red: 100/255, green: 116/255, blue: 139/255)
}

// MARK: - Models

struct Chapter: Identifiable, Hashable {
    let id: String
    let name: String
    let state: String
}

struct MemberProfile {
    let name: String
    let role: String
    let grade: String
    let leadershipPoints: Int
}

struct Announcement: Identifiable {
    let id: String
    let title: String
    let tag: String
}

struct ChapterEvent: Identifiable {
    let id: String
    let title: String
    let date: String
    let time: String
    let location: String
}

struct ResourceItem: Identifiable {
    let id: String
    let name: String
    let type: String
    let detail: String
}

struct NewsItem: Identifiable {
    let id: String
    let headline: String
    let source: String
    let timeAgo: String
}

struct CommunityChannel: Identifiable {
    let id: String
    let platform: String
    let handle: String
    let activity: String
    let url: String
}

struct ReminderSetting: Identifiable {
    let id: String
    let name: String
    let enabledLabel: String
}

struct CustomReminder: Identifiable, Codable {
    let id: String
    let title: String
    let dueDate: String
}

// MARK: - Store

@MainActor
final class AppStore: ObservableObject {
    @Published var selectedChapterID: String = ""
    @Published var customReminders: [CustomReminder] = []

    let chapters: [Chapter] = [
        Chapter(id: "northview-hs", name: "Northview High School", state: "GA"),
        Chapter(id: "lincoln-hs", name: "Lincoln High School", state: "TX"),
        Chapter(id: "crestmont-hs", name: "Crestmont High School", state: "FL"),
        Chapter(id: "ridgeway-hs", name: "Ridgeway High School", state: "NC"),
        Chapter(id: "westlake-hs", name: "Westlake High School", state: "CA")
    ]

    let profile = MemberProfile(name: "Jordan Lee", role: "Chapter Vice President", grade: "11th Grade", leadershipPoints: 1420)

    let announcements: [Announcement] = [
        Announcement(id: "a1", title: "State Leadership Conference registration closes March 22", tag: "Deadline"),
        Announcement(id: "a2", title: "March chapter challenge: community service sprint", tag: "Earn up to 150 points"),
        Announcement(id: "a3", title: "New Business Ethics prep packet added", tag: "Study Resource"),
        Announcement(id: "a4", title: "Officer meeting agenda posted", tag: "Wednesday 4:15 PM")
    ]

    let events: [ChapterEvent] = [
        ChapterEvent(id: "e1", title: "Chapter Meeting", date: "Mar 6", time: "4:15 PM", location: "Business Lab 204"),
        ChapterEvent(id: "e2", title: "Resume Workshop", date: "Mar 9", time: "3:30 PM", location: "Media Center"),
        ChapterEvent(id: "e3", title: "Mock Interview Night", date: "Mar 12", time: "5:30 PM", location: "Auditorium"),
        ChapterEvent(id: "e4", title: "District Competition", date: "Mar 16", time: "8:00 AM", location: "Central HS"),
        ChapterEvent(id: "e5", title: "Community Service Drive", date: "Mar 20", time: "2:00 PM", location: "Downtown Hub"),
        ChapterEvent(id: "e6", title: "State Prep Session", date: "Mar 25", time: "4:00 PM", location: "Room 110")
    ]

    let resources: [ResourceItem] = [
        ResourceItem(id: "r1", name: "Competitive Event Study Guides", type: "PDF Pack", detail: "15 event-specific prep guides"),
        ResourceItem(id: "r2", name: "Officer Handbook", type: "Document", detail: "Bylaws, duties, and planning templates"),
        ResourceItem(id: "r3", name: "Resume Builder Kit", type: "Template Set", detail: "ATS-friendly resume and cover letter"),
        ResourceItem(id: "r4", name: "Interview Practice Bank", type: "Question Bank", detail: "100 common interview prompts"),
        ResourceItem(id: "r5", name: "Project Rubric Hub", type: "Rubrics", detail: "Scoring criteria for chapter projects"),
        ResourceItem(id: "r6", name: "Financial Literacy Mini Course", type: "Video Series", detail: "6 short lessons and quizzes")
    ]

    let news: [NewsItem] = [
        NewsItem(id: "n1", headline: "Chapter wins regional sweepstakes award", source: "FBLA Chapter News", timeAgo: "2h ago"),
        NewsItem(id: "n2", headline: "National FBLA shares event-theme updates", source: "National FBLA", timeAgo: "6h ago"),
        NewsItem(id: "n3", headline: "Local leaders join mentorship network", source: "Community Bulletin", timeAgo: "1d ago"),
        NewsItem(id: "n4", headline: "Three members qualify for nationals in data analysis", source: "Competition Desk", timeAgo: "2d ago"),
        NewsItem(id: "n5", headline: "Fundraiser exceeds target by 38 percent", source: "Chapter Treasurer", timeAgo: "3d ago")
    ]

    let communityChannels: [CommunityChannel] = [
        CommunityChannel(id: "c1", platform: "Instagram", handle: "@northview_fbla", activity: "Daily event tips and recap reels", url: "https://www.instagram.com"),
        CommunityChannel(id: "c2", platform: "X", handle: "@northviewFBLA", activity: "Competition reminders and updates", url: "https://x.com"),
        CommunityChannel(id: "c3", platform: "LinkedIn", handle: "Northview FBLA Alumni", activity: "Career networking and internships", url: "https://www.linkedin.com"),
        CommunityChannel(id: "c4", platform: "YouTube", handle: "Northview FBLA Media", activity: "Tutorials and officer recaps", url: "https://www.youtube.com"),
        CommunityChannel(id: "c5", platform: "Discord", handle: "FBLA Study Server", activity: "Peer study channels by event", url: "https://discord.com")
    ]

    let reminderSettings: [ReminderSetting] = [
        ReminderSetting(id: "s1", name: "Competition deadlines", enabledLabel: "Enabled"),
        ReminderSetting(id: "s2", name: "Meeting reminders", enabledLabel: "Enabled"),
        ReminderSetting(id: "s3", name: "Resource updates", enabledLabel: "Enabled"),
        ReminderSetting(id: "s4", name: "Mentorship opportunities", enabledLabel: "Enabled")
    ]

    private let chapterKey = "fbla_connect.selected_chapter"
    private let remindersKey = "fbla_connect.custom_reminders"

    var selectedChapter: Chapter? { chapters.first(where: { $0.id == selectedChapterID }) }

    init() { loadState() }

    func chooseChapter(_ chapterID: String) {
        selectedChapterID = chapterID
        UserDefaults.standard.set(chapterID, forKey: chapterKey)
    }

    func addReminder(title: String, dueDate: String) {
        let reminder = CustomReminder(id: UUID().uuidString, title: title.trimmingCharacters(in: .whitespacesAndNewlines), dueDate: dueDate.trimmingCharacters(in: .whitespacesAndNewlines))
        customReminders.insert(reminder, at: 0)
        saveReminders()
    }

    func deleteReminder(_ reminder: CustomReminder) {
        customReminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }

    private func loadState() {
        if let savedChapter = UserDefaults.standard.string(forKey: chapterKey) { selectedChapterID = savedChapter }

        guard let data = UserDefaults.standard.data(forKey: remindersKey) else {
            customReminders = [
                CustomReminder(id: "seed1", title: "Submit SLC permission form", dueDate: "2026-03-18"),
                CustomReminder(id: "seed2", title: "Practice objective test set B", dueDate: "2026-03-22"),
                CustomReminder(id: "seed3", title: "Upload final presentation slides", dueDate: "2026-03-27")
            ]
            return
        }

        customReminders = (try? JSONDecoder().decode([CustomReminder].self, from: data)) ?? []
    }

    private func saveReminders() {
        if let data = try? JSONEncoder().encode(customReminders) {
            UserDefaults.standard.set(data, forKey: remindersKey)
        }
    }
}

// MARK: - Reusable Views

struct BrandHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(colors: [FBLATheme.navy, FBLATheme.royal, FBLATheme.brightBlue], startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image("FBLALogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(FBLATheme.gold.opacity(0.9), lineWidth: 1))

                    Text("FBLA CONNECT")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                }

                Text(title)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.9))
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(FBLATheme.gold.opacity(0.25), lineWidth: 1))
    }
}

struct InfoCard: View {
    let title: String
    var subtitle: String? = nil
    var meta: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(FBLATheme.text)
            if let subtitle { Text(subtitle).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundStyle(FBLATheme.muted) }
            if let meta { Text(meta).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(FBLATheme.brightBlue) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(FBLATheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))
    }
}

struct ChapterPickerCard: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected Chapter")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(FBLATheme.muted)

            Picker("Chapter", selection: $store.selectedChapterID) {
                ForEach(store.chapters) { chapter in
                    Text("\(chapter.name) (\(chapter.state))").tag(chapter.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: store.selectedChapterID) { _, newValue in
                store.chooseChapter(newValue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(FBLATheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))
    }
}

// MARK: - Screens

struct ChapterOnboardingView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                FBLATheme.page.ignoresSafeArea()

                VStack(spacing: 16) {
                    BrandHeader(title: "Choose Your Chapter", subtitle: "Select your FBLA chapter before entering the app")

                    VStack(alignment: .leading, spacing: 10) {
                        Text("FBLA Chapter")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(FBLATheme.muted)

                        Picker("Chapter", selection: $store.selectedChapterID) {
                            Text("Select a chapter").tag("")
                            ForEach(store.chapters) { chapter in
                                Text("\(chapter.name) (\(chapter.state))").tag(chapter.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))

                    Button("Continue") {
                        store.chooseChapter(store.selectedChapterID)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(store.selectedChapterID.isEmpty ? FBLATheme.muted : FBLATheme.brightBlue)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .disabled(store.selectedChapterID.isEmpty)

                    Spacer()
                }
                .padding(16)
            }
        }
    }
}

struct HomeTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(title: "Welcome Back", subtitle: store.selectedChapter?.name ?? "FBLA Chapter")

                HStack(spacing: 10) {
                    statCard(title: "Points", value: "\(store.profile.leadershipPoints)")
                    statCard(title: "Upcoming", value: "\(store.events.count)")
                }

                ForEach(store.announcements) { item in
                    InfoCard(title: item.title, meta: item.tag)
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value).font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(FBLATheme.brightBlue)
            Text(title).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundStyle(FBLATheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))
    }
}

struct ProfileTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(title: "Member Profile", subtitle: "Manage profile and chapter selection")
                InfoCard(title: store.profile.name, subtitle: "\(store.profile.role) • \(store.profile.grade)", meta: "Leadership Points: \(store.profile.leadershipPoints)")
                ChapterPickerCard()
                InfoCard(title: "Competition Track", subtitle: "Business Plan, UX Design, Networking Infrastructures", meta: "3 active events")
                InfoCard(title: "Volunteer Hours", subtitle: "42 hours logged this season", meta: "Chapter verified")
                InfoCard(title: "Mentorship", subtitle: "Paired with local business leader", meta: "Active")
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}

struct TimelineTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var title: String = ""
    @State private var dueDate: String = ""
    @State private var error: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(title: "Events & Reminders", subtitle: "Track chapter schedule and create reminders")

                ForEach(store.events) { event in
                    InfoCard(title: event.title, subtitle: "\(event.date) at \(event.time) • \(event.location)", meta: "Upcoming")
                }

                ForEach(store.reminderSettings) { item in
                    InfoCard(title: item.name, meta: item.enabledLabel)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Custom Reminder").font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(FBLATheme.text)
                    TextField("Title (min 4 chars)", text: $title).textFieldStyle(.roundedBorder)
                    TextField("Due date YYYY-MM-DD", text: $dueDate).textFieldStyle(.roundedBorder)

                    if !error.isEmpty {
                        Text(error).font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(.red)
                    }

                    Button("Save Reminder") { saveReminder() }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(canSubmit ? FBLATheme.brightBlue : FBLATheme.muted)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(!canSubmit)
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))

                ForEach(store.customReminders) { reminder in
                    VStack(alignment: .leading, spacing: 6) {
                        InfoCard(title: reminder.title, subtitle: "Due: \(reminder.dueDate)")
                        Button(role: .destructive) { store.deleteReminder(reminder) } label: { Text("Delete").font(.system(size: 12, weight: .bold, design: .rounded)) }
                    }
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }

    private var canSubmit: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4 && isDateFormatted(dueDate)
    }

    private func saveReminder() {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 { error = "Title must be at least 4 characters."; return }
        if !isDateFormatted(dueDate) { error = "Date must use YYYY-MM-DD format."; return }

        store.addReminder(title: title, dueDate: dueDate)
        title = ""
        dueDate = ""
        error = ""
    }

    private func isDateFormatted(_ date: String) -> Bool {
        date.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil
    }
}

struct ResourcesTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var query: String = ""

    var filtered: [ResourceItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return store.resources }
        return store.resources.filter { $0.name.lowercased().contains(q) || $0.type.lowercased().contains(q) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(title: "Resources", subtitle: "Search study content and officer docs")
                TextField("Search resources", text: $query).textFieldStyle(.roundedBorder)
                ForEach(filtered) { item in
                    InfoCard(title: item.name, subtitle: "\(item.type) • \(item.detail)", meta: "Open")
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}

struct NewsTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(title: "News Feed", subtitle: "Chapter and national FBLA updates")
                ForEach(store.news) { item in
                    InfoCard(title: item.headline, subtitle: item.source, meta: item.timeAgo)
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}

struct CommunityTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(title: "Community", subtitle: "Social channels and networking")
                ForEach(store.communityChannels) { channel in
                    Link(destination: URL(string: channel.url)!) {
                        InfoCard(title: "\(channel.platform) • \(channel.handle)", subtitle: channel.activity, meta: "Open")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}
