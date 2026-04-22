import XCTest
@testable import PokemonCardSim

final class PackOpeningServiceTests: XCTestCase {
    func testCategorizeCommonRarity() {
        XCTAssertEqual(RarityWeights.category(forRarityString: "Common"), .common)
        XCTAssertEqual(RarityWeights.category(forRarityString: "Uncommon"), .uncommon)
    }

    func testOpenPackHasTenCards() throws {
        var rng = 0.5
        var service = PackOpeningService()
        service.random = { rng }
        let pool = (0..<50).map { i in
            PTCGCard(
                id: "x-\(i)",
                name: "Card \(i)",
                rarity: "Common",
                images: PTCGCardImages(small: "https://example.com/s.png", large: "https://example.com/l.png"),
                set: PTCGCardSetInfo(id: "base1", name: "Base"),
                tcgplayer: nil
            )
        }
        let out = try service.openPack(cards: pool)
        XCTAssertEqual(out.count, 10)
    }
}
