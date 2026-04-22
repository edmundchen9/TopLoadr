import SwiftData
import XCTest
@testable import PokemonCardSim

@MainActor
final class CreditsServiceTests: XCTestCase {
    func testAwardAndSpend() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserProfile.self, configurations: config)
        let context = ModelContext(container)
        let s = CreditsService()
        s.award(100, reason: "test", context: context)
        XCTAssertEqual(s.ensureProfile(context).credits, 1000 + 100)
        try s.spend(200, context: context)
        XCTAssertEqual(s.ensureProfile(context).credits, 900)
    }
}
