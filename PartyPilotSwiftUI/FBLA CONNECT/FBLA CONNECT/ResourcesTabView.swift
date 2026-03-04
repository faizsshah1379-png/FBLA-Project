import SwiftUI

/// Resources tab for key FBLA links and documents.
struct ResourcesTabView: View {
    @EnvironmentObject var store: MemberAppStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        AppPage(title: "Resources", subtitle: "Core FBLA documents and learning resources.") {
            // Search by resource name/category.
            TextField("Search resources", text: $store.resourceFilter)
                .textFieldStyle(.roundedBorder)

            ForEach(store.filteredResources) { item in
                VStack(alignment: .leading, spacing: 8) {
                    StandardCard(title: item.name, subtitle: item.detail, meta: item.category)
                    Button("Open Resource") {
                        // Open resource in browser.
                        if let url = URL(string: item.url) {
                            openURL(url)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}
