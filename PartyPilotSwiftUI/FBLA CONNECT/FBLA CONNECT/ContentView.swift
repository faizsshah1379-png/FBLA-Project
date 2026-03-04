import SwiftUI

/// Root view that owns shared app state (`MemberAppStore`) and injects it
/// into each tab via `environmentObject`.
struct ContentView: View {
    /// One shared state object for the whole app lifecycle.
    @StateObject private var store = MemberAppStore()
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
                TabView {
                    // Home dashboard tab.
                    HomeTabView()
                        .environmentObject(store)
                        .tabItem { Label("Home", systemImage: "house.fill") }

                    // Member profile tab.
                    ProfileTabView()
                        .environmentObject(store)
                        .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }

                    // Calendar + reminders tab.
                    CalendarTabView()
                        .environmentObject(store)
                        .tabItem { Label("Calendar", systemImage: "calendar") }

                    // Resource links tab.
                    ResourcesTabView()
                        .environmentObject(store)
                        .tabItem { Label("Resources", systemImage: "folder.fill") }

                    // Personalized news feed tab.
                    NewsTabView()
                        .environmentObject(store)
                        .tabItem { Label("News", systemImage: "newspaper.fill") }

                    // Community + social + team connect tab.
                    CommunityTabView()
                        .environmentObject(store)
                        .tabItem { Label("Community", systemImage: "person.3.fill") }
                }
                .tint(Theme.primary)
                .offset(y: tabViewOffset)
                .opacity(tabViewOpacity)

                if showIntroOverlay {
                    ZStack {
                        Color.white
                            .ignoresSafeArea()

                        Text("Welcome to FBLA Connect")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.navy)
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
