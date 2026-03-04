import SwiftUI

/// Reusable page shell used by each tab:
/// gradient header + scrolling content area.
struct AppPage<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header section.
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 29, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.92))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(LinearGradient(colors: [Theme.navy, Theme.primary, Theme.sky], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                // Caller-provided content.
                content
            }
            .padding(16)
        }
        .background(Theme.page.ignoresSafeArea())
    }
}

/// Generic card used all over the app for clean, consistent information blocks.
struct StandardCard: View {
    let title: String
    let subtitle: String
    var meta: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.text)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.muted)
            if let meta {
                Text(meta)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.blue.opacity(0.09), lineWidth: 1))
    }
}

/// Small stat row used on Home (events/reminders/updates).
struct MetricRow: View {
    let items: [(String, String)]

    var body: some View {
        HStack(spacing: 9) {
            ForEach(Array(items.enumerated()), id: \.offset) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.element.0)
                        .font(.headline)
                        .foregroundStyle(Theme.primary)
                    Text(item.element.1)
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

/// Labeled text input used by profile/reminders/team form fields.
struct LabeledInput: View {
    let label: String
    @Binding var text: String
    var placeholder = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.muted)
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

/// Shared section title style.
struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.title3)
            .fontWeight(.bold)
    }
}
