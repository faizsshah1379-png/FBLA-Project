import SwiftUI

/// Personalized news feed tab.
/// Shows state-priority updates based on chapter text.
struct NewsTabView: View {
    @EnvironmentObject var store: MemberAppStore

    var body: some View {
        AppPage(title: "News Feed", subtitle: "Announcements and updates from chapter, state, and national FBLA.") {
            // Visual confirmation of personalization context.
            StandardCard(
                title: "Personalized by Chapter",
                subtitle: "Current chapter: \(store.profile.chapter)",
                meta: "Showing \(store.detectedState) FBLA priority updates"
            )

            // Keyword filter across title/source/body.
            TextField("Search announcements", text: $store.newsFilter)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Theme.field)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Theme.stroke, lineWidth: 1)
                )

            ForEach(store.filteredAnnouncements) { item in
                StandardCard(title: item.title, subtitle: item.body, meta: "\(item.source) | \(item.posted)")
            }
        }
    }
}
