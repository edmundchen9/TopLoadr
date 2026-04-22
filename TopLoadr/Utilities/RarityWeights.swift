import Foundation

/// Buckets for simplified pack simulation (not era-accurate).
enum RarityCategory: String, CaseIterable {
    case common
    case uncommon
    case rare
    case holo
    case ultra
    case secret
}

enum RarityWeights {
    /// For the final “hit” slot, pick one of these pools with weighted probability.
    static let hitSlotWeights: [(RarityCategory, Double)] = [
        (.holo, 0.70),
        (.ultra, 0.25),
        (.secret, 0.05)
    ]

    /// Classify a Pokémon TCG API `rarity` string.
    static func category(forRarityString rarity: String?) -> RarityCategory {
        let r = (rarity ?? "").lowercased()

        if r.isEmpty { return .common }

        if r.contains("secret") || r.contains("special illustration") { return .secret }
        if r.contains("ultra") || r.contains("illustration rare") { return .ultra }
        if r.contains("double rare") { return .ultra }
        if r.contains("rare holo") || r == "holo rare" { return .holo }
        if r == "holo" { return .holo }
        if r == "rare" || r.hasPrefix("rare ") { return .rare }
        if r == "uncommon" { return .uncommon }
        if r == "common" { return .common }
        if r.contains("rare") { return .rare }
        return .common
    }
}
