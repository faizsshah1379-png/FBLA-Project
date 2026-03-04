import SwiftUI

struct ChapterPickerCard: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected Chapter")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(FBLATheme.muted)

            Picker("Chapter", selection: $store.selectedChapterID) {
                ForEach(store.chapters) { chapter in
                    Text("\(chapter.name) (\(chapter.state))")
                        .tag(chapter.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: store.selectedChapterID) { _, newValue in
                store.chooseChapter(newValue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(FBLATheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1)
        )
    }
}
