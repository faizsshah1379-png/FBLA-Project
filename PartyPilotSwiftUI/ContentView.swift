import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @State private var introStarted = false
    @State private var introCompleted = false
    @State private var showIntroOverlay = true
    @State private var introOffset: CGFloat = 0
    @State private var tabViewOffset: CGFloat = 1200
    @State private var tabViewOpacity: Double = 0

    private var showChapterOnboarding: Binding<Bool> {
        Binding(
            get: { store.selectedChapter == nil },
            set: { _ in }
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let travelDistance = proxy.size.height + 140

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
                .offset(y: tabViewOffset)
                .opacity(tabViewOpacity)

                if showIntroOverlay {
                    ZStack {
                        Color.white
                            .ignoresSafeArea()

                        Text("Welcome to FBLA Connect")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(FBLATheme.navy)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .offset(y: introOffset)
                    .zIndex(1)
                }
            }
            .clipped()
            .onAppear {
                startIntroIfNeeded(travelDistance: travelDistance)
            }
            .onChange(of: store.selectedChapter) { _ in
                startIntroIfNeeded(travelDistance: travelDistance)
            }
        }
        .fullScreenCover(isPresented: showChapterOnboarding) {
            ChapterOnboardingView()
                .environmentObject(store)
        }
    }

    private func startIntroIfNeeded(travelDistance: CGFloat) {
        guard !introCompleted else {
            showIntroOverlay = false
            introOffset = -travelDistance
            tabViewOffset = 0
            tabViewOpacity = 1
            return
        }

        guard store.selectedChapter != nil else { return }
        guard !introStarted else { return }

        introStarted = true
        showIntroOverlay = true
        introOffset = 0
        tabViewOffset = travelDistance
        tabViewOpacity = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.55)) {
                introOffset = -travelDistance
            }

            withAnimation(.interpolatingSpring(stiffness: 175, damping: 17).delay(0.1)) {
                tabViewOffset = 0
                tabViewOpacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                showIntroOverlay = false
                introCompleted = true
            }
        }
    }
}
