import SwiftUI

struct CardDetailView: View {
    let card: OwnedCard
    @State private var scale: CGFloat = 1.0
    @State private var baseScale: CGFloat = 1.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let u = URL(string: card.largeImageURL.isEmpty ? card.smallImageURL : card.largeImageURL) {
                    AsyncImage(url: u) { phase in
                        switch phase {
                        case .empty: ProgressView()
                        case .success(let i):
                            i
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(scale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { v in
                                            let next = baseScale * v
                                            scale = min(max(0.5, next), 4.0)
                                        }
                                        .onEnded { _ in baseScale = scale }
                                )
                        case .failure:
                            ContentUnavailableView("Image unavailable", systemImage: "photo")
                        @unknown default: EmptyView()
                        }
                    }
                }
                Group {
                    Text(card.name)
                        .font(.title2.bold())
                    if let r = card.rarity {
                        Text("Rarity: \(r)").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Text("Quantity: ×\(card.quantity)").font(.subheadline)
                }
                if let s = card.tcgPlayerURL, let l = URL(string: s) {
                    Link("View on TCGPlayer", destination: l)
                        .buttonStyle(.borderedProminent)
                } else {
                    Text("No TCGPlayer link for this card in the API.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { Text("—") }
