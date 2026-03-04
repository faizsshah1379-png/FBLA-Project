import SwiftUI

/// Community tab includes:
/// - shareable member card
/// - teammate connection manager
/// - social media links
struct CommunityTabView: View {
    @EnvironmentObject var store: MemberAppStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        AppPage(title: "Community", subtitle: "Connect to chapter social channels and broader FBLA community.") {
            SectionTitle("Share Member Card")
            ShareLink(item: store.memberShareText) {
                Label("Share My FBLA Details", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            SectionTitle("Team Connect")
            LabeledInput(label: "Teammate Name", text: $store.connectionName, placeholder: "Ex: Alex Rivera")
            LabeledInput(label: "Competition Event", text: $store.connectionEvent, placeholder: "Ex: Mobile Application Development")
            LabeledInput(label: "Contact (Email or Phone)", text: $store.connectionContact, placeholder: "alex@school.edu")

            // Form validation message.
            if let message = store.connectionValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Add Connection") {
                store.addConnection()
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.connectionValidationMessage != nil)

            // Saved teammate connections.
            ForEach(store.connections) { connection in
                HStack {
                    StandardCard(title: connection.name, subtitle: "Event: \(connection.event)", meta: connection.contact)
                    Button(role: .destructive) {
                        store.deleteConnection(connection.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete connection \(connection.name)")
                }
            }

            SectionTitle("Chapter Social Channels")
            ForEach(store.socialChannels) { channel in
                VStack(alignment: .leading, spacing: 8) {
                    StandardCard(title: channel.platform, subtitle: channel.handle)
                    HStack(spacing: 12) {
                        socialActionButton(symbol: appSymbol(for: channel), accessibilityLabel: "Open \(channel.platform) app") {
                            openApp(for: channel)
                        }

                        socialActionButton(symbol: "desktopcomputer", accessibilityLabel: "Open \(channel.platform) on web") {
                            openWeb(for: channel)
                        }
                    }
                }
            }
        }
    }

    private func socialActionButton(symbol: String, accessibilityLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.primary)
                .frame(width: 44, height: 44)
                .background(Theme.surface)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Theme.stroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func appSymbol(for channel: SocialChannel) -> String {
        switch channel.platform.lowercased() {
        case "instagram":
            return "camera.circle.fill"
        case "youtube":
            return "play.rectangle.fill"
        case "linkedin":
            return "link.circle.fill"
        case "x":
            return "at.circle.fill"
        default:
            return "app.fill"
        }
    }

    private func openApp(for channel: SocialChannel) {
        guard let appURL = URL(string: channel.appURL) else { return }
        // If deep-link fails (app not installed), fallback to web.
        openURL(appURL) { accepted in
            if !accepted {
                openWeb(for: channel)
            }
        }
    }

    private func openWeb(for channel: SocialChannel) {
        guard let webURL = URL(string: channel.webURL) else { return }
        openURL(webURL)
    }
}
