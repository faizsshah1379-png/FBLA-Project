import SwiftUI

struct InfoCard: View {
    let title: String
    var subtitle: String? = nil
    var meta: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(FBLATheme.text)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(FBLATheme.muted)
            }

            if let meta {
                Text(meta)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(FBLATheme.brightBlue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(FBLATheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(red: 230/255, green: 238/255, blue: 249/255), lineWidth: 1)
        )
    }
}
