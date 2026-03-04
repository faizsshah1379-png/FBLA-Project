import SwiftUI

/// Root view that owns shared app state (`MemberAppStore`) and injects it
/// into each tab via `environmentObject`.
struct ContentView: View {
    /// One shared state object for the whole app lifecycle.
    @StateObject private var store = MemberAppStore()
    @State private var selectedTab = 0
    @State private var introStarted = false
    @State private var introCompleted = false
    @State private var showIntroOverlay = true
    @State private var introOffset: CGFloat = 0
    @State private var tabViewOffset: CGFloat = 1200
    @State private var tabViewOpacity: Double = 0

    var body: some View {
        GeometryReader { proxy in
            let travelDistance = proxy.size.height + 140

            ZStack {
                TabView(selection: $selectedTab) {
                    // Home dashboard tab.
                    HomeTabView(selectedTab: $selectedTab)
                        .environmentObject(store)
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(0)

                    // Member profile tab.
                    ProfileTabView()
                        .environmentObject(store)
                        .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                        .tag(1)

                    // Calendar + reminders tab.
                    CalendarTabView()
                        .environmentObject(store)
                        .tabItem { Label("Calendar", systemImage: "calendar") }
                        .tag(2)

                    // Resource links tab.
                    ResourcesTabView()
                        .environmentObject(store)
                        .tabItem { Label("Resources", systemImage: "folder.fill") }
                        .tag(3)

                    // Personalized news feed tab.
                    NewsTabView()
                        .environmentObject(store)
                        .tabItem { Label("News", systemImage: "newspaper.fill") }
                        .tag(4)
                }
                .tint(Theme.primary)
                .offset(y: tabViewOffset)
                .opacity(tabViewOpacity)

                if showIntroOverlay {
                    ZStack {
                        Theme.page
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            Text("Welcome to FBLA Connect")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.text)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            Image("FBLALogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 152, height: 152)
                                .accessibilityHidden(true)
                        }
                    }
                    .offset(y: introOffset)
                    .zIndex(1)
                }
            }
            .onAppear {
                startIntroIfNeeded(travelDistance: travelDistance)
            }
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

#Preview {
    ContentView()
}
