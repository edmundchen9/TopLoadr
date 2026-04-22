import SwiftUI

struct CardThumbnail: View {
    var imageURL: URL?
    var name: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.15))
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let img):
                    img
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                @unknown default:
                    Color.clear
                }
            }
            .padding(2)
        }
        .frame(minHeight: 120)
        .overlay(alignment: .bottom) {
            Text(name)
                .font(.caption2)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(4)
                .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    CardThumbnail(imageURL: nil, name: "Pikachu")
        .frame(width: 100)
}
