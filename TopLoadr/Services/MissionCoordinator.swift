import Foundation
import SwiftData

@MainActor
enum MissionCoordinator {
    static func seedIfEmpty(_ context: ModelContext) {
        let fd = FetchDescriptor<Mission>()
        let count = (try? context.fetch(fd).count) ?? 0
        if count > 0 { return }
        context.insert(Mission(type: .openPacksToday, target: 3, creditReward: 100))
        context.insert(Mission(type: .watchRewardStreak, target: 1, creditReward: 50))
        context.insert(Mission(type: .collectRares, target: 2, creditReward: 75))
    }

    static func onPackOpened(_ context: ModelContext) {
        let fd = FetchDescriptor<Mission>()
        guard
            let m = (try? context.fetch(fd))?
                .first(where: { $0.kind == .openPacksToday && !$0.isComplete && !$0.isClaimed })
        else { return }
        m.progress += 1
    }

    static func onAdWatched(_ context: ModelContext) {
        let fd = FetchDescriptor<Mission>()
        guard
            let m = (try? context.fetch(fd))?
                .first(where: { $0.kind == .watchRewardStreak && !$0.isComplete && !$0.isClaimed })
        else { return }
        m.progress = m.target
    }

    static func onRareObtainedIfNew(
        _ context: ModelContext,
        wasNewInsert: Bool,
        rarity: String?
    ) {
        guard wasNewInsert else { return }
        let cat = RarityWeights.category(forRarityString: rarity)
        switch cat {
        case .rare, .holo, .ultra, .secret:
            break
        default:
            return
        }
        let fd = FetchDescriptor<Mission>()
        guard
            let m = (try? context.fetch(fd))?
                .first(where: { $0.kind == .collectRares && !$0.isComplete && !$0.isClaimed })
        else { return }
        m.progress += 1
    }
}
