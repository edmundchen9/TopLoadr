import SwiftUI

struct PackArtwork: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.35)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                VStack(spacing: 4) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 32))
                    Text("Booster")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
            }
            .frame(height: 100)
    }
}

#Preview { PackArtwork() }
