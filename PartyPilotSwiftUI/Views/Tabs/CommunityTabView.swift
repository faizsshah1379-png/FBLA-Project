import SwiftUI

struct CommunityTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(
                    title: "Community",
                    subtitle: "Social channels and chapter networking"
                )

                ForEach(store.communityChannels) { channel in
                    Link(destination: URL(string: channel.url)!) {
                        InfoCard(
                            title: "\(channel.platform) • \(channel.handle)",
                            subtitle: channel.activity,
                            meta: "Open"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}
