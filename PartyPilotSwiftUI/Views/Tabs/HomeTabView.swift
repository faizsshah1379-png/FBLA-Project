import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(
                    title: "Welcome Back",
                    subtitle: store.selectedChapter?.name ?? "FBLA Chapter"
                )

                HStack(spacing: 10) {
                    statCard(title: "Points", value: "\(store.profile.leadershipPoints)")
                    statCard(title: "Upcoming Events", value: "\(store.events.count)")
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
            Text(value)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(FBLATheme.brightBlue)
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(FBLATheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))
    }
}
