import SwiftUI

struct CardRevealView: View {
    let card: PTCGCard

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            CardThumbnail(
                imageURL: (card.images.small).flatMap(URL.init(string:)),
                name: card.name
            )
            if let r = card.rarity {
                Text(r)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
