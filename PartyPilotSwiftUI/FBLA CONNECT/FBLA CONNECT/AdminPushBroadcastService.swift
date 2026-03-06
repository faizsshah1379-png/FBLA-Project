import Foundation

enum AdminPushBroadcastService {
    private static let endpointOverrideKey = "fbla.push.broadcast.endpoint.v1"
    private static let defaultFunctionsRegion = "us-central1"
    private static let broadcastFunctionName = "sendBroadcastNotification"

    private struct RequestBody: Encodable {
        let title: String
        let body: String
    }

    private struct ErrorBody: Decodable {
        let error: String?
        let message: String?
    }

    enum BroadcastError: LocalizedError {
        case missingEndpoint
        case invalidServerResponse
        case unauthorized
        case server(String)

        var errorDescription: String? {
            switch self {
            case .missingEndpoint:
                return "No push endpoint available. Deploy sendBroadcastNotification Cloud Function first."
            case .invalidServerResponse:
                return "Push server returned an invalid response."
            case .unauthorized:
                return "You are not authorized to send notifications."
            case .server(let message):
                return message
            }
        }
    }

    static func sendBroadcast(idToken: String, title: String, body: String) async throws {
        guard let endpoint = broadcastEndpoint() else {
            throw BroadcastError.missingEndpoint
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(RequestBody(title: title, body: body))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BroadcastError.invalidServerResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw BroadcastError.unauthorized
            }
            if httpResponse.statusCode == 404 {
                throw BroadcastError.server("Push function not found. Deploy sendBroadcastNotification in Firebase Functions.")
            }

            if let decoded = try? JSONDecoder().decode(ErrorBody.self, from: data),
               let message = decoded.message ?? decoded.error,
               !message.isEmpty {
                throw BroadcastError.server(message)
            }

            throw BroadcastError.server("Push broadcast failed (\(httpResponse.statusCode)).")
        }
    }

    static func configuredEndpointDisplayValue() -> String {
        endpointOverrideString() ?? plistEndpointString() ?? inferredEndpointString() ?? ""
    }

    static func saveEndpointOverride(_ rawEndpoint: String) -> Bool {
        guard let normalized = normalizedEndpointString(from: rawEndpoint) else {
            UserDefaults.standard.removeObject(forKey: endpointOverrideKey)
            return true
        }

        guard URL(string: normalized) != nil else { return false }
        UserDefaults.standard.set(normalized, forKey: endpointOverrideKey)
        return true
    }

    private static func broadcastEndpoint() -> URL? {
        if let override = endpointOverrideString(),
            let url = URL(string: override) {
            return url
        }

        if let raw = plistEndpointString(),
           let url = URL(string: raw) {
            return url
        }

        if let inferred = inferredEndpointString(),
           let url = URL(string: inferred) {
            return url
        }

        return nil
    }

    private static func endpointOverrideString() -> String? {
        guard let raw = UserDefaults.standard.string(forKey: endpointOverrideKey) else {
            return nil
        }

        return normalizedEndpointString(from: raw)
    }

    private static func plistEndpointString() -> String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "PUSH_BROADCAST_ENDPOINT") as? String else {
            return nil
        }
        return normalizedEndpointString(from: raw)
    }

    private static func inferredEndpointString() -> String? {
        guard let projectID = firebaseProjectID() else { return nil }
        return "https://\(defaultFunctionsRegion)-\(projectID).cloudfunctions.net/\(broadcastFunctionName)"
    }

    private static func firebaseProjectID() -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
              let projectID = plist["PROJECT_ID"] as? String else {
            return nil
        }

        let trimmed = projectID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed
    }

    private static func normalizedEndpointString(from raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if trimmed.hasPrefix("https://") || trimmed.hasPrefix("http://") {
            return trimmed
        }

        return "https://\(trimmed)"
    }
}
