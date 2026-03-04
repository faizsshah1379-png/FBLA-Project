import SwiftUI

struct BrandHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [FBLATheme.navy, FBLATheme.royal, FBLATheme.brightBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image("FBLALogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(FBLATheme.gold.opacity(0.9), lineWidth: 1)
                        )
                        .accessibilityLabel("FBLA Logo")

                    Text("FBLA CONNECT")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                }

                Text(title)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.9))
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(FBLATheme.gold.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: FBLATheme.navy.opacity(0.2), radius: 10, y: 5)
    }
}
