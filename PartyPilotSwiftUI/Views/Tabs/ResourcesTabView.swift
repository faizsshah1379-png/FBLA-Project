import SwiftUI

struct ResourcesTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var query: String = ""

    var filtered: [ResourceItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return store.resources }
        return store.resources.filter { $0.name.lowercased().contains(q) || $0.type.lowercased().contains(q) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                BrandHeader(
                    title: "Resources",
                    subtitle: "Search study content, templates, and officer documents"
                )

                TextField("Search resources", text: $query)
                    .textFieldStyle(.roundedBorder)

                ForEach(filtered) { item in
                    InfoCard(title: item.name, subtitle: "\(item.type) • \(item.detail)", meta: "Open")
                }
            }
            .padding(16)
        }
        .background(FBLATheme.page)
    }
}
