import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif

/// App entry point.
/// SwiftUI starts here and loads the root view (`ContentView`).
@main
struct FBLA_CONNECTApp: App {
    init() {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootGateView()
        }
    }
}
