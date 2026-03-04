import SwiftUI

/// Member profile editor tab.
/// Profile values are used for personalization (news/events).
struct ProfileTabView: View {
    @EnvironmentObject var store: MemberAppStore

    var body: some View {
        AppPage(title: "Member Profile", subtitle: "Personal member identity and chapter engagement details.") {
            // Editable fields bound directly to shared store state.
            LabeledInput(label: "Full Name", text: $store.profile.name)
            LabeledInput(label: "Chapter", text: $store.profile.chapter)
            LabeledInput(label: "Leadership Role", text: $store.profile.role)
            LabeledInput(label: "Graduation Year", text: $store.profile.gradYear)
            LabeledInput(label: "Interests", text: $store.profile.interests)

            // Persist profile to local storage.
            Button("Save Profile") {
                store.saveProfile()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Save member profile")
        }
    }
}
