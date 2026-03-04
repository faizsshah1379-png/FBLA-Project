import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    private var showChapterOnboarding: Binding<Bool> {
        Binding(
            get: { store.selectedChapter == nil },
            set: { _ in }
        )
    }

    var body: some View {
        ZStack {
            FBLATheme.page.ignoresSafeArea()

            TabView {
                HomeTabView()
                    .tabItem { Label("Home", systemImage: "house.fill") }

                ProfileTabView()
                    .tabItem { Label("Profile", systemImage: "person.circle.fill") }

                TimelineTabView()
                    .tabItem { Label("Timeline", systemImage: "calendar") }

                ResourcesTabView()
                    .tabItem { Label("Resources", systemImage: "folder.fill") }

                NewsTabView()
                    .tabItem { Label("News", systemImage: "newspaper.fill") }

                CommunityTabView()
                    .tabItem { Label("Community", systemImage: "person.3.fill") }
            }
            .tint(FBLATheme.brightBlue)
        }
        .fullScreenCover(isPresented: showChapterOnboarding) {
            ChapterOnboardingView()
                .environmentObject(store)
        }
    }
}
