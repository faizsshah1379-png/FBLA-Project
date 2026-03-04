import SwiftUI

/// Root view that owns shared app state (`MemberAppStore`) and injects it
/// into each tab via `environmentObject`.
struct ContentView: View {
    /// One shared state object for the whole app lifecycle.
    @StateObject private var store = MemberAppStore()

    var body: some View {
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
        // Global accent/tint color for tab and action controls.
        .tint(Theme.primary)
    }
}

#Preview {
    ContentView()
}
