import Foundation
import SwiftData

@MainActor
final class DailyLoginService {
    private let calendar = Calendar.current

    /// Awards daily bonus once per local calendar day.
    func checkAndApplyDailyBonus(
        _ context: ModelContext,
        credits: CreditsService
    ) {
        let p = credits.ensureProfile(context)
        if let last = p.lastLoginDate, calendar.isDateInToday(last) {
            return
        }
        p.lastLoginDate = Date()
        credits.award(
            AppConstants.dailyLoginBonus,
            reason: "daily_login",
            context: context
        )
    }
}
