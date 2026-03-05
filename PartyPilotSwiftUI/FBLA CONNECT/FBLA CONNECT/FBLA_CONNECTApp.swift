import SwiftUI

/// App entry point.
/// SwiftUI starts here and loads the root view (`ContentView`).
@main
struct FBLA_CONNECTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootGateView()
        }
    }
}
