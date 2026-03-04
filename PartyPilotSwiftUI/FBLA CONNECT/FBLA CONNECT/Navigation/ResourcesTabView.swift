import SwiftUI

/// Resources tab for key FBLA links and documents.
struct ResourcesTabView: View {
    @EnvironmentObject var store: MemberAppStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        AppPage(title: "Resources", subtitle: "Core FBLA documents and learning resources.") {
            ForEach(store.filteredResources) { item in
                Button {
                    // Open resource in browser.
                    if let url = URL(string: item.url) {
                        openURL(url)
                    }
                } label: {
                    resourceCard(for: item)
                }
                .buttonStyle(.plain)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                    .overlay(Theme.stroke)

                searchField
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
            }
            .background(Theme.page.opacity(0.98))
        }
    }

    private var searchField: some View {
        TextField("Search resources", text: $store.resourceFilter)
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
    }

    private func resourceCard(for item: ResourceItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.text)

            Text(item.detail)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.muted)

            Text(item.category)
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
