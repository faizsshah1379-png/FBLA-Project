import SwiftUI

struct NewsTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(
                    title: "News Feed",
                    subtitle: "Stay updated on chapter and national FBLA activity"
                )

                ForEach(store.news) { item in
                    InfoCard(title: item.headline, subtitle: item.source, meta: item.timeAgo)
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}
