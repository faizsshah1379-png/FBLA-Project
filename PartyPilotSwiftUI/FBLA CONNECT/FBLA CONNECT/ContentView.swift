import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isBusy = false
    @Published var authError: String?

    func signIn(email: String, password: String) async {
        authError = nil
        isBusy = true
        defer { isBusy = false }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !cleanPassword.isEmpty else {
            authError = "Enter your email and password."
            return
        }

        isAuthenticated = true
    }

    func createAccount(email: String, password: String) async {
        authError = nil
        isBusy = true
        defer { isBusy = false }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !cleanPassword.isEmpty else {
            authError = "Enter email and password to create an account."
            return
        }

        isAuthenticated = true
    }

    func resetPassword(email: String) async {
        authError = nil
        isBusy = true
        defer { isBusy = false }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty else {
            authError = "Enter your email to reset password."
            return
        }

        do {
            try await sendPasswordResetViaREST(email: cleanEmail)
            authError = "Password reset email sent."
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() {
        authError = nil

        isAuthenticated = false
    }

    private func sendPasswordResetViaREST(email: String) async throws {
        guard let apiKey = firebaseWebAPIKey(), !apiKey.isEmpty else {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase API key. Add GoogleService-Info.plist to the app target."])
        }

        guard let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=\(apiKey)") else {
            throw NSError(domain: "Auth", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid Firebase endpoint URL."])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "requestType": "PASSWORD_RESET",
            "email": email
        ])

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "Auth", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not send reset email. Check that Email/Password is enabled in Firebase Auth."])
        }
    }

    private func firebaseWebAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = plist["API_KEY"] as? String else {
            return nil
        }
        return apiKey
    }
}

struct RootGateView: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        Group {
            if auth.isAuthenticated {
                ContentView()
                    .environmentObject(auth)
            } else {
                LoginView(auth: auth)
            }
        }
    }
}

struct LoginView: View {
    @ObservedObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 80)

                Image("FBLALogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .padding(.bottom, 52)

                Text("Sign In")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Sign in to your account")
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .padding(.top, 4)
                    .padding(.bottom, 42)

                VStack(spacing: 18) {
                    TextField("Email Address", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 64)
                        .background(Color(red: 0.09, green: 0.1, blue: 0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .frame(height: 64)
                        .background(Color(red: 0.09, green: 0.1, blue: 0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                Button {
                    Task { await auth.signIn(email: email, password: password) }
                } label: {
                    Text(auth.isBusy ? "Signing In..." : "Sign In")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color(red: 0.08, green: 0.52, blue: 0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(auth.isBusy)
                .padding(.top, 26)

                Button {
                    Task { await auth.createAccount(email: email, password: password) }
                } label: {
                    Text("New User? Create Account.")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.08, green: 0.52, blue: 0.96))
                .padding(.top, 32)
                .disabled(auth.isBusy)

                Button {
                    Task { await auth.resetPassword(email: email) }
                } label: {
                    Text("Forgot Password?")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.08, green: 0.52, blue: 0.96))
                .padding(.top, 28)
                .disabled(auth.isBusy)

                if let authError = auth.authError {
                    Text(authError)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding(.horizontal, 10)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

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
    RootGateView()
}
