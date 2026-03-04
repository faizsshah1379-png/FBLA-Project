import SwiftUI

/// Personalized news feed tab.
/// Shows state-priority updates based on chapter text.
struct NewsTabView: View {
    @EnvironmentObject var store: MemberAppStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        AppPage(title: "News Feed", subtitle: "Announcements and updates from chapter, state, and national FBLA.") {
            // Visual confirmation of personalization context.
            Button {
                if let url = URL(string: "https://www.fbla.org/chapter-management/") {
                    openURL(url)
                }
            } label: {
                StandardCard(
                    title: "Personalized by Chapter",
                    subtitle: "Current chapter: \(store.profile.chapter)",
                    meta: "Showing \(store.detectedState) FBLA priority updates"
                )
            }
            .buttonStyle(.plain)

            ForEach(store.filteredAnnouncements) { item in
                Button {
                    if let url = URL(string: item.url) {
                        openURL(url)
                    }
                } label: {
                    newsCard(for: item)
                }
                .buttonStyle(.plain)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            searchField
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color.clear)
        }
    }

    private var searchField: some View {
        TextField("Search announcements", text: $store.newsFilter)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Theme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.stroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
    }

    private func newsCard(for item: AnnouncementItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.text)

            Text(item.body)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.muted)

            Text("\(item.source) | \(item.posted)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }
}
