import Foundation

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
