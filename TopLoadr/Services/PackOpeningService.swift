import Foundation

/// 10-card pack: 5 common, 3 uncommon, 1 rare, 1 weighted “hit” (holo / ultra / secret).
struct PackOpeningService {
    var random: @Sendable () -> Double = { Double.random(in: 0..<1) }

    func openPack(cards: [PTCGCard]) throws -> [PTCGCard] {
        guard !cards.isEmpty else { throw PackOpeningError.emptyPool }

        var buckets: [RarityCategory: [PTCGCard]] = [:]
        for c in RarityCategory.allCases { buckets[c] = [] }
        for card in cards {
            let cat = RarityWeights.category(forRarityString: card.rarity)
            buckets[cat, default: []].append(card)
        }

        func pick(from category: RarityCategory) -> PTCGCard? {
            guard var pool = buckets[category], !pool.isEmpty else { return nil }
            let i = Int(random() * Double(pool.count)) % pool.count
            return pool[i]
        }

        /// Prefer exact bucket; fall back through related pools; never returns nil if total pool non-empty
        func pickResolving(from preferred: RarityCategory) -> PTCGCard {
            if let c = pick(from: preferred) { return c }
            // Fallback order
            let order: [RarityCategory] = [
                preferred,
                .rare, .holo, .ultra, .uncommon, .common, .secret
            ]
            var seen = Set<RarityCategory>()
            for p in order where !seen.contains(p) {
                seen.insert(p)
                if let c = pick(from: p) { return c }
            }
            // Any card
            return cards.randomElement()!
        }

        // Roll hit category first
        let hitRoll = random()
        var acc = 0.0
        var hitCategory: RarityCategory = .holo
        for (cat, w) in RarityWeights.hitSlotWeights {
            acc += w
            if hitRoll < acc {
                hitCategory = cat
                break
            }
        }

        var result: [PTCGCard] = []
        for _ in 0..<5 { result.append(pickResolving(from: .common)) }
        for _ in 0..<3 { result.append(pickResolving(from: .uncommon)) }
        result.append(pickResolving(from: .rare))
        result.append(pickResolving(from: hitCategory))

        return result
    }
}

enum PackOpeningError: LocalizedError {
    case emptyPool

    var errorDescription: String? {
        switch self {
        case .emptyPool: return "This set has no cards to open."
        }
    }
}
