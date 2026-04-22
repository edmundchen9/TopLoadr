import Foundation
import SwiftData

enum MissionType: String, CaseIterable, Codable {
    case openPacksToday
    case watchRewardStreak
    case collectRares
}

@Model
final class Mission {
    var typeRaw: String
    var progress: Int
    var target: Int
    var creditReward: Int
    var claimedAt: Date?

    var isComplete: Bool { progress >= target }
    var isClaimed: Bool { claimedAt != nil }

    init(type: MissionType, target: Int, creditReward: Int) {
        self.typeRaw = type.rawValue
        self.progress = 0
        self.target = max(1, target)
        self.creditReward = creditReward
        self.claimedAt = nil
    }

    var displayTitle: String {
        switch kind {
        case .openPacksToday: return "Open \(target) pack(s) today"
        case .watchRewardStreak: return "Use “Watch ad” once"
        case .collectRares: return "Add \(target) rare+ card to collection"
        }
    }
}

extension Mission {
    var kind: MissionType {
        MissionType(rawValue: typeRaw) ?? .openPacksToday
    }
}
