import Foundation

/// Pokémon TCG API set (see https://docs.pokemontcg.io)
struct PTCGSet: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var series: String?
    var printedTotal: Int?
    var total: Int
    var releaseDate: String?
    var images: PTCGSetImages?

    var logoURL: URL? {
        guard let s = images?.logo else { return nil }
        return URL(string: s)
    }

    var symbolURL: URL? {
        guard let s = images?.symbol else { return nil }
        return URL(string: s)
    }
}

struct PTCGSetImages: Codable, Hashable {
    var symbol: String?
    var logo: String?
}
