import Foundation
import SwiftData

@Model
final class OwnedCard {
    @Attribute(.unique) var cardID: String
    var setID: String
    var setName: String
    var name: String
    var quantity: Int
    var smallImageURL: String
    var largeImageURL: String
    var rarity: String?
    var tcgPlayerURL: String?
    var firstObtainedAt: Date

    init(
        cardID: String,
        setID: String,
        setName: String,
        name: String,
        quantity: Int,
        smallImageURL: String,
        largeImageURL: String,
        rarity: String?,
        tcgPlayerURL: String?
    ) {
        self.cardID = cardID
        self.setID = setID
        self.setName = setName
        self.name = name
        self.quantity = quantity
        self.smallImageURL = smallImageURL
        self.largeImageURL = largeImageURL
        self.rarity = rarity
        self.tcgPlayerURL = tcgPlayerURL
        self.firstObtainedAt = Date()
    }
}

extension OwnedCard: Identifiable {
    var id: String { cardID }
}

extension PTCGCard {
    func toOwnedCard(quantity: Int) -> OwnedCard {
        let setID = set?.id ?? "unknown"
        let setName = set?.name ?? "Unknown Set"
        return OwnedCard(
            cardID: id,
            setID: setID,
            setName: setName,
            name: name,
            quantity: quantity,
            smallImageURL: images.small ?? "https://images.pokemontcg.io/placeholder/small.png",
            largeImageURL: images.large ?? (images.small ?? "https://images.pokemontcg.io/placeholder/large.png"),
            rarity: rarity,
            tcgPlayerURL: tcgplayer?.url
        )
    }
}
