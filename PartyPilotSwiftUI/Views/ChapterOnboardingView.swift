import SwiftUI

struct ChapterOnboardingView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                FBLATheme.page.ignoresSafeArea()

                VStack(spacing: 16) {
                    BrandHeader(
                        title: "Choose Your Chapter",
                        subtitle: "Select the FBLA chapter you belong to before entering the app."
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("FBLA Chapter")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(FBLATheme.muted)

                        Picker("Chapter", selection: $store.selectedChapterID) {
                            Text("Select a chapter").tag("")
                            ForEach(store.chapters) { chapter in
                                Text("\(chapter.name) (\(chapter.state))").tag(chapter.id)
                            }
                        }
                        .pickerStyle(.menu)

                        Text("You can change this later in Profile.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(FBLATheme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1))

                    Button {
                        store.chooseChapter(store.selectedChapterID)
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(store.selectedChapterID.isEmpty ? FBLATheme.muted : FBLATheme.brightBlue)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(store.selectedChapterID.isEmpty)

                    Spacer()
                }
                .padding(16)
            }
        }
    }
}
