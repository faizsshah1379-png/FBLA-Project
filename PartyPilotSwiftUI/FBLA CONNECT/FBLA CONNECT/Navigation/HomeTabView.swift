import SwiftUI

/// Home dashboard tab showing app purpose and high-level feature summary.
struct HomeTabView: View {
    @EnvironmentObject var store: MemberAppStore
    @Binding var selectedTab: Int

    var body: some View {
        AppPage(
            title: "FBLA Connect",
            subtitle: "Official student member companion app for staying informed, connected, and engaged.",
            greeting: "Hi \(store.profile.firstName),",
            greetingTopPadding: 10
        ) {
            // Quick at-a-glance stats.
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    metricCard(value: "\(store.chapterEvents.count)", label: "Events")
                    metricCard(value: "\(store.reminders.count)", label: "Reminders")
                }

                metricCard(value: "\(store.filteredAnnouncements.count)", label: "Updates")
            }

            Text("What You Can Do")
                .font(.system(size: 31, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.text)
                .padding(.top, 6)
                .padding(.bottom, 2)

            tabCard(
                title: "Member Profile",
                subtitle: "View and update chapter, role, graduation year, and interests.",
                destination: 1,
                icon: "person.crop.circle.fill"
            )
            tabCard(
                title: "Calendar & Reminders",
                subtitle: "Track meetings, competition deadlines, and custom reminders.",
                destination: 2,
                icon: "calendar.badge.clock"
            )
            tabCard(
                title: "Resources",
                subtitle: "Open key FBLA materials, guides, and official links.",
                destination: 3,
                icon: "folder.fill"
            )
            tabCard(
                title: "News Feed",
                subtitle: "Follow chapter, state, and national updates in one stream.",
                destination: 4,
                icon: "newspaper.fill"
            )
            tabCard(
                title: "Community & Social",
                subtitle: "Manage teammate connections and open chapter social channels from your profile tab.",
                destination: 1,
                icon: "person.3.fill"
            )
        }
    }

    private func metricCard(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 31, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.primary)

            Text(label)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }

    private func tabCard(title: String, subtitle: String, destination: Int, icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = destination
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.text)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                }

                Spacer(minLength: 8)

                Image(systemName: icon)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Theme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(Theme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
