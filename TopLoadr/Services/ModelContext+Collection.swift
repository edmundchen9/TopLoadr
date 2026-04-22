import Foundation
import SwiftData

extension ModelContext {
    @MainActor
    func addPulledCards(_ cards: [PTCGCard]) {
        for card in cards {
            let cid = card.id
            let pred = #Predicate<OwnedCard> { $0.cardID == cid }
            let fd = FetchDescriptor<OwnedCard>(predicate: pred)
            if let found = (try? fetch(fd))?.first {
                found.quantity += 1
            } else {
                let owned = card.toOwnedCard(quantity: 1)
                insert(owned)
                MissionCoordinator.onRareObtainedIfNew(self, wasNewInsert: true, rarity: card.rarity)
            }
        }
    }
}
