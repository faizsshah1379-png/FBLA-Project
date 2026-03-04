import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(
                    title: "Member Profile",
                    subtitle: "Manage profile and chapter selection"
                )

                InfoCard(
                    title: store.profile.name,
                    subtitle: "\(store.profile.role) • \(store.profile.grade)",
                    meta: "Leadership Points: \(store.profile.leadershipPoints)"
                )

                ChapterPickerCard()

                InfoCard(title: "Competition Track", subtitle: "Business Plan, UX Design, and Networking Infrastructures", meta: "3 active events")
                InfoCard(title: "Volunteer Hours", subtitle: "42 hours logged this season", meta: "Chapter verified")
                InfoCard(title: "Mentorship", subtitle: "Paired with local business leader for monthly coaching", meta: "Active")
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}
