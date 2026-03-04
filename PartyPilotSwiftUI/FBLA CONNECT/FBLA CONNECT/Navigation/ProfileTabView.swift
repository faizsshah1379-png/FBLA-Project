import SwiftUI

/// Member profile editor tab.
/// Profile values are used for personalization (news/events).
struct ProfileTabView: View {
    @EnvironmentObject var store: MemberAppStore
    @Environment(\.openURL) private var openURL
    @State private var mode: ProfileMode = .editing
    @State private var checkmarkScale: CGFloat = 0.35
    @State private var checkmarkOpacity = 0.0
    @State private var checkmarkRotation = -18.0
    @State private var showingConnectionForm = false
    @State private var savingConnection = false
    @State private var connectionCheckmarkScale: CGFloat = 0.35
    @State private var connectionCheckmarkOpacity = 0.0
    @State private var connectionCheckmarkRotation = -18.0

    private enum ProfileMode {
        case editing
        case saving
        case summary
    }

    var body: some View {
        AppPage(
            title: "Member Profile",
            subtitle: "Personal member identity and chapter engagement details.",
            showHeader: false
        ) {
            switch mode {
            case .editing:
                editingView
            case .saving:
                savingView
            case .summary:
                savedSummaryView
            }

            if mode != .saving {
                Divider()
                    .padding(.top, 6)
                communityContent
            }
        }
    }

    private var editingView: some View {
        VStack(alignment: .leading, spacing: 14) {
            profileCard(
                title: "Member Profile",
                subtitle: "\(store.profile.chapter) • \(store.profile.role)"
            )

            profileInput(label: "First Name", text: $store.profile.firstName, placeholder: "Ex: Jordan")
            profileInput(label: "Last Name", text: $store.profile.lastName, placeholder: "Ex: Lee")
            profileInput(label: "Chapter", text: $store.profile.chapter, placeholder: "Ex: Franklin High School")
            profileInput(label: "Leadership Role", text: $store.profile.role, placeholder: "Ex: Chapter VP")
            profileInput(label: "Graduation Year", text: $store.profile.gradYear, placeholder: "Ex: 2027")
            profileInput(label: "Interests", text: $store.profile.interests, placeholder: "Ex: Event Planning, Finance")

            Button("Save Profile") {
                saveProfileAndShowConfirmation()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Save member profile")
        }
    }

    private var savingView: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 24)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100, weight: .semibold))
                .foregroundStyle(Color.green)
                .scaleEffect(checkmarkScale)
                .opacity(checkmarkOpacity)
                .rotationEffect(.degrees(checkmarkRotation))

            Text("Profile Saved")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.text)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity)
    }

    private var savedSummaryView: some View {
        VStack(alignment: .leading, spacing: 14) {
            profileCard(
                title: store.profile.fullName,
                subtitle: "\(store.profile.chapter) • \(store.profile.role)"
            )

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    mode = .editing
                }
            } label: {
                HStack {
                    Text("Change")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "pencil")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func profileCard(title: String, subtitle: String) -> some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [Theme.navy, Theme.primary, Theme.sky],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.93))

                ShareLink(item: store.memberShareText) {
                    Label("Share My FBLA Details", systemImage: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.42), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 190)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Theme.stroke.opacity(0.65), lineWidth: 1)
        )
    }

    private func profileInput(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)

            TextField(placeholder, text: text)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(Theme.field)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Theme.stroke, lineWidth: 1)
                )
        }
    }

    private var communityContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle("Team Connect")
            LazyVGrid(columns: connectionGridColumns, spacing: 12) {
                ForEach(store.connections) { connection in
                    connectionCard(connection)
                }

                addConnectionCard
            }

            if showingConnectionForm {
                if savingConnection {
                    connectionSavedCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    connectionInputCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
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

    private var connectionGridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    private func connectionCard(_ connection: TeamConnection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Text(connection.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)

                Spacer(minLength: 6)

                Button(role: .destructive) {
                    store.deleteConnection(connection.id)
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete connection \(connection.name)")
            }

            Text(connection.event)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.muted)
                .lineLimit(2)

            Text(connection.contact)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.primary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 152, maxHeight: 152, alignment: .topLeading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }

    private var addConnectionCard: some View {
        Button {
            toggleConnectionForm()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.primary)

                Text("Add Connection")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.center)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 152, maxHeight: 152)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add teammate connection")
    }

    private var connectionInputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            LabeledInput(label: "Teammate Name", text: $store.connectionName, placeholder: "Ex: Alex Rivera")
            LabeledInput(label: "Competition Event", text: $store.connectionEvent, placeholder: "Ex: Mobile Application Development")
            LabeledInput(label: "Contact (Email or Phone)", text: $store.connectionContact, placeholder: "alex@school.edu")

            if let message = store.connectionValidationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button("Save Connection") {
                saveConnectionAndShowConfirmation()
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.connectionValidationMessage != nil)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
    }

    private var connectionSavedCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 86, weight: .semibold))
                .foregroundStyle(Color.green)
                .scaleEffect(connectionCheckmarkScale)
                .opacity(connectionCheckmarkOpacity)
                .rotationEffect(.degrees(connectionCheckmarkRotation))

            Text("Connection Saved")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.text)
        }
        .frame(maxWidth: .infinity, minHeight: 182)
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
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

    private func toggleConnectionForm() {
        guard !savingConnection else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            showingConnectionForm.toggle()
        }

        if !showingConnectionForm {
            store.connectionName = ""
            store.connectionEvent = ""
            store.connectionContact = ""
        }
    }

    private func saveConnectionAndShowConfirmation() {
        guard store.connectionValidationMessage == nil else { return }
        store.addConnection()
        savingConnection = true
        connectionCheckmarkScale = 0.35
        connectionCheckmarkOpacity = 0
        connectionCheckmarkRotation = -18

        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            connectionCheckmarkScale = 1
            connectionCheckmarkOpacity = 1
            connectionCheckmarkRotation = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeInOut(duration: 0.22)) {
                savingConnection = false
                showingConnectionForm = false
            }
        }
    }

    private func saveProfileAndShowConfirmation() {
        store.saveProfile()
        mode = .saving
        checkmarkScale = 0.35
        checkmarkOpacity = 0
        checkmarkRotation = -18

        withAnimation(.spring(response: 0.48, dampingFraction: 0.7)) {
            checkmarkScale = 1
            checkmarkOpacity = 1
            checkmarkRotation = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            withAnimation(.easeInOut(duration: 0.22)) {
                mode = .summary
            }
        }
    }
}
