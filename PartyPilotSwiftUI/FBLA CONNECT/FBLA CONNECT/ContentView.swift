import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isBusy = false
    @Published var authError: String?
    private let authSessionKey = "fbla.auth.session.v1"

    init() {
        isAuthenticated = loadStoredSession() != nil
    }

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

        do {
            let session = try await authenticateWithFirebaseREST(
                endpoint: "signInWithPassword",
                email: cleanEmail,
                password: cleanPassword
            )
            storeSession(session)
            withAnimation(.easeInOut(duration: 0.45)) {
                isAuthenticated = true
            }
        } catch {
            authError = error.localizedDescription
        }
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

        do {
            let session = try await authenticateWithFirebaseREST(
                endpoint: "signUp",
                email: cleanEmail,
                password: cleanPassword
            )
            storeSession(session)
            withAnimation(.easeInOut(duration: 0.45)) {
                isAuthenticated = true
            }
        } catch {
            authError = error.localizedDescription
        }
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
        clearStoredSession()

        withAnimation(.easeInOut(duration: 0.35)) {
            isAuthenticated = false
        }
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

    private func authenticateWithFirebaseREST(endpoint: String, email: String, password: String) async throws -> AuthSession {
        guard let apiKey = firebaseWebAPIKey(), !apiKey.isEmpty else {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase API key. Add GoogleService-Info.plist to the app target."])
        }

        guard let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:\(endpoint)?key=\(apiKey)") else {
            throw NSError(domain: "Auth", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid Firebase endpoint URL."])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Auth", code: 3, userInfo: [NSLocalizedDescriptionKey: "No response from Firebase."])
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = firebaseAuthErrorMessage(from: data)
            throw NSError(domain: "Auth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        do {
            return try JSONDecoder().decode(AuthSession.self, from: data)
        } catch {
            throw NSError(domain: "Auth", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unexpected Firebase login response."])
        }
    }

    private func firebaseAuthErrorMessage(from data: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = json["error"] as? [String: Any],
           let code = error["message"] as? String {
            switch code {
            case "EMAIL_NOT_FOUND":
                return "No account found for this email."
            case "INVALID_PASSWORD":
                return "Incorrect password."
            case "INVALID_LOGIN_CREDENTIALS":
                return "Invalid email or password."
            case "EMAIL_EXISTS":
                return "An account with this email already exists."
            case "WEAK_PASSWORD : Password should be at least 6 characters":
                return "Password must be at least 6 characters."
            case "OPERATION_NOT_ALLOWED":
                return "Enable Email/Password sign-in in Firebase Authentication."
            default:
                return code.replacingOccurrences(of: "_", with: " ").capitalized
            }
        }

        return "Authentication failed. Please try again."
    }

    private func firebaseWebAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = plist["API_KEY"] as? String else {
            return nil
        }
        return apiKey
    }

    private func loadStoredSession() -> AuthSession? {
        guard let data = UserDefaults.standard.data(forKey: authSessionKey) else { return nil }
        return try? JSONDecoder().decode(AuthSession.self, from: data)
    }

    private func storeSession(_ session: AuthSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: authSessionKey)
    }

    private func clearStoredSession() {
        UserDefaults.standard.removeObject(forKey: authSessionKey)
    }
}

private struct AuthSession: Codable {
    let idToken: String
    let refreshToken: String
    let localId: String
    let email: String
}

struct RootGateView: View {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var store = MemberAppStore()

    var body: some View {
        ZStack {
            if auth.isAuthenticated {
                ContentView(store: store)
                    .environmentObject(auth)
                    .transition(.opacity)
            } else {
                LoginView(auth: auth, store: store)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: auth.isAuthenticated)
    }
}

struct LoginView: View {
    @ObservedObject var auth: AuthViewModel
    @ObservedObject var store: MemberAppStore

    @State private var email = ""
    @State private var password = ""
    @State private var showCreateAccountSheet = false
    @State private var signupEmail = ""
    @State private var signupPassword = ""
    @State private var signupFirstName = ""
    @State private var signupLastName = ""
    @State private var signupChapter = ""
    @State private var signupError: String?

    var body: some View {
        ZStack {
            Theme.page.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 80)

                Image("FBLALogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .padding(.bottom, 52)

                Text("Sign In")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)

                Text("Sign in to your account")
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 4)
                    .padding(.bottom, 42)

                VStack(spacing: 18) {
                    TextField("Email Address", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 18)
                        .frame(height: 64)
                        .background(Theme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Theme.stroke, lineWidth: 1)
                        )

                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 18)
                        .frame(height: 64)
                        .background(Theme.field)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Theme.stroke, lineWidth: 1)
                        )
                }

                Button {
                    Task { await auth.signIn(email: email, password: password) }
                } label: {
                    Text(auth.isBusy ? "Signing In..." : "Sign In")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(auth.isBusy)
                .padding(.top, 26)

                Button {
                    signupError = nil
                    if signupEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        signupEmail = email
                    }
                    if signupPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        signupPassword = password
                    }
                    showCreateAccountSheet = true
                } label: {
                    Text("New User? Create Account.")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Theme.primary)
                .padding(.top, 32)
                .disabled(auth.isBusy)

                Button {
                    Task { await auth.resetPassword(email: email) }
                } label: {
                    Text("Forgot Password?")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                }
                .foregroundStyle(Theme.primary)
                .padding(.top, 28)
                .disabled(auth.isBusy)

                if let authError = auth.authError {
                    Text(authError)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.text.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .padding(.horizontal, 10)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showCreateAccountSheet) {
            createAccountSheet
        }
    }

    private var createAccountSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tell us about your membership")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.text)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.text)

                        TextField("Email Address", text: $signupEmail)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress)
                            .foregroundStyle(Theme.text)
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(Theme.field)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Theme.stroke, lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.text)

                        SecureField("Password", text: $signupPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .foregroundStyle(Theme.text)
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(Theme.field)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Theme.stroke, lineWidth: 1)
                            )
                    }

                    signupInputField(title: "First Name", text: $signupFirstName)
                    signupInputField(title: "Last Name", text: $signupLastName)
                    signupInputField(title: "Chapter", text: $signupChapter)

                    if let signupError {
                        Text(signupError)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.text.opacity(0.75))
                            .multilineTextAlignment(.leading)
                    }

                    if let authError = auth.authError, signupError == nil {
                        Text(authError)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.text.opacity(0.75))
                            .multilineTextAlignment(.leading)
                    }

                    Button {
                        Task { await submitCreateAccount() }
                    } label: {
                        Text(auth.isBusy ? "Creating Account..." : "Create Account")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Theme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(auth.isBusy)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(Theme.page.ignoresSafeArea())
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCreateAccountSheet = false
                    }
                    .disabled(auth.isBusy)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func signupInputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.text)

            TextField(title, text: text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Theme.field)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Theme.stroke, lineWidth: 1)
                )
        }
    }

    private func submitCreateAccount() async {
        signupError = nil

        let signupEmailValue = signupEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let signupPasswordValue = signupPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName = signupFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = signupLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let chapter = signupChapter.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !signupEmailValue.isEmpty, !signupPasswordValue.isEmpty else {
            signupError = "Enter email address and password."
            return
        }

        guard !firstName.isEmpty, !lastName.isEmpty, !chapter.isEmpty else {
            signupError = "Enter first name, last name, and chapter."
            return
        }

        await auth.createAccount(email: signupEmailValue, password: signupPasswordValue)

        guard auth.isAuthenticated else {
            signupError = auth.authError
            return
        }

        store.updateProfileFromSignup(firstName: firstName, lastName: lastName, chapter: chapter)
        email = signupEmailValue
        password = signupPasswordValue
        showCreateAccountSheet = false
        signupEmail = ""
        signupPassword = ""
        signupFirstName = ""
        signupLastName = ""
        signupChapter = ""
    }
}

/// Root view that owns shared app state (`MemberAppStore`) and injects it
/// into each tab via `environmentObject`.
struct ContentView: View {
    /// Shared state object for the authenticated app lifecycle.
    @ObservedObject var store: MemberAppStore
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
