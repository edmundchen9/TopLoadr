import Foundation
import SwiftData

@MainActor
final class CreditsService {
    func ensureProfile(_ context: ModelContext) -> UserProfile {
        let fd = FetchDescriptor<UserProfile>()
        if let p = try? context.fetch(fd).first {
            return p
        }
        let p = UserProfile(credits: AppConstants.startingCredits)
        context.insert(p)
        return p
    }

    /// Single funnel for all credit grants.
    func award(
        _ amount: Int,
        reason: String,
        context: ModelContext,
        allowPremiumBonus: Bool = true
    ) {
        let p = ensureProfile(context)
        var grant = max(0, amount)
        if allowPremiumBonus, p.isPremium {
            grant = Int((Double(grant) * 1.1).rounded())
        }
        p.credits += grant
        _ = reason
    }

    func canAfford(_ cost: Int, context: ModelContext) -> Bool {
        ensureProfile(context).credits >= cost
    }

    @discardableResult
    func spend(_ cost: Int, context: ModelContext) throws -> Int {
        let p = ensureProfile(context)
        guard p.credits >= cost else { throw CreditError.insufficient }
        p.credits -= cost
        return p.credits
    }

    func setPremium(_ isPremium: Bool, context: ModelContext) {
        ensureProfile(context).isPremium = isPremium
    }

    /// Pack cost with optional premium discount.
    func currentPackPrice(context: ModelContext) -> Int {
        let p = ensureProfile(context)
        var cost = AppConstants.packCostCredits
        if p.isPremium { cost = max(1, cost - AppConstants.premiumPackDiscount) }
        return cost
    }
}

enum CreditError: LocalizedError {
    case insufficient

    var errorDescription: String? {
        switch self {
        case .insufficient: return "Not enough credits."
        }
    }
}
