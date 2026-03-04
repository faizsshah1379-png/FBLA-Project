import SwiftUI

/// Home dashboard tab showing app purpose and high-level feature summary.
struct HomeTabView: View {
    @EnvironmentObject var store: MemberAppStore

    var body: some View {
        AppPage(title: "FBLA Connect", subtitle: "Official student member companion app for staying informed, connected, and engaged.") {
            // Quick at-a-glance stats.
            MetricRow(items: [
                ("\(store.chapterEvents.count)", "Events"),
                ("\(store.reminders.count)", "Reminders"),
                ("\(store.filteredAnnouncements.count)", "Updates")
            ])

            SectionTitle("What You Can Do")
            StandardCard(title: "Member Profile", subtitle: "View and update chapter, role, graduation year, and interests.")
            StandardCard(title: "Calendar & Reminders", subtitle: "Track meetings, competition deadlines, and custom reminders.")
            StandardCard(title: "Resources", subtitle: "Open key FBLA materials, guides, and official links.")
            StandardCard(title: "News Feed", subtitle: "Follow chapter, state, and national updates in one stream.")
            StandardCard(title: "Social Integration", subtitle: "Jump directly to chapter channels on Instagram, X, YouTube, and LinkedIn.")
        }
    }
}
