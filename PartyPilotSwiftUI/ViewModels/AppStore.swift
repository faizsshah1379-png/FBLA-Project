import Foundation

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

    let profile = MemberProfile(
        name: "Jordan Lee",
        role: "Chapter Vice President",
        grade: "11th Grade",
        leadershipPoints: 1420
    )

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

    var selectedChapter: Chapter? {
        chapters.first(where: { $0.id == selectedChapterID })
    }

    init() {
        loadState()
    }

    func chooseChapter(_ chapterID: String) {
        selectedChapterID = chapterID
        UserDefaults.standard.set(chapterID, forKey: chapterKey)
    }

    func addReminder(title: String, dueDate: String) {
        let reminder = CustomReminder(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        customReminders.insert(reminder, at: 0)
        saveReminders()
    }

    func deleteReminder(_ reminder: CustomReminder) {
        customReminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }

    private func loadState() {
        if let savedChapter = UserDefaults.standard.string(forKey: chapterKey) {
            selectedChapterID = savedChapter
        }

        guard let data = UserDefaults.standard.data(forKey: remindersKey) else {
            customReminders = [
                CustomReminder(id: "seed1", title: "Submit SLC permission form", dueDate: "2026-03-18"),
                CustomReminder(id: "seed2", title: "Practice objective test set B", dueDate: "2026-03-22"),
                CustomReminder(id: "seed3", title: "Upload final presentation slides", dueDate: "2026-03-27")
            ]
            return
        }

        do {
            customReminders = try JSONDecoder().decode([CustomReminder].self, from: data)
        } catch {
            customReminders = []
        }
    }

    private func saveReminders() {
        do {
            let data = try JSONEncoder().encode(customReminders)
            UserDefaults.standard.set(data, forKey: remindersKey)
        } catch {
            // Keep UI responsive even if persistence encoding fails.
        }
    }
}
