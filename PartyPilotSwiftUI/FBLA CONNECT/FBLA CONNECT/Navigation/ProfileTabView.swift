import SwiftUI

/// Member profile editor tab.
/// Profile values are used for personalization (news/events).
struct ProfileTabView: View {
    @EnvironmentObject var store: MemberAppStore
    @State private var mode: ProfileMode = .editing
    @State private var checkmarkScale: CGFloat = 0.35
    @State private var checkmarkOpacity = 0.0
    @State private var checkmarkRotation = -18.0

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
        }
    }

    private var editingView: some View {
        VStack(alignment: .leading, spacing: 14) {
            profileCard(
                title: "Member Profile",
                subtitle: "Update your chapter identity details for a personalized FBLA CONNECT experience."
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

            profileSummaryField(label: "First Name", value: store.profile.firstName)
            profileSummaryField(label: "Last Name", value: store.profile.lastName)
            profileSummaryField(label: "Chapter", value: store.profile.chapter)
            profileSummaryField(label: "Leadership Role", value: store.profile.role)
            profileSummaryField(label: "Graduation Year", value: store.profile.gradYear)
            profileSummaryField(label: "Interests", value: store.profile.interests)

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

    private func profileSummaryField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.muted)

            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        )
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
