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
                    HStack {
                        Button("Open in App") {
                            if let appURL = URL(string: channel.appURL) {
                                // If deep-link fails (app not installed), fallback to web.
                                openURL(appURL) { accepted in
                                    if !accepted, let webURL = URL(string: channel.webURL) {
                                        openURL(webURL)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Open on Web") {
                            if let webURL = URL(string: channel.webURL) {
                                openURL(webURL)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}
