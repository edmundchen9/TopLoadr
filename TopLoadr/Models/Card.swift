import Foundation

/// Pokémon TCG API card
struct PTCGCard: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var rarity: String?
    var images: PTCGCardImages
    var set: PTCGCardSetInfo?
    var tcgplayer: PTCGTCGPlayer?

    init(
        id: String,
        name: String,
        rarity: String?,
        images: PTCGCardImages,
        set: PTCGCardSetInfo? = nil,
        tcgplayer: PTCGTCGPlayer? = nil
    ) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.images = images
        self.set = set
        self.tcgplayer = tcgplayer
    }
}

struct PTCGCardSetInfo: Codable, Hashable {
    var id: String
    var name: String
}

struct PTCGCardImages: Codable, Hashable {
    var small: String?
    var large: String?
}

struct PTCGTCGPlayer: Codable, Hashable {
    var url: String?
}
