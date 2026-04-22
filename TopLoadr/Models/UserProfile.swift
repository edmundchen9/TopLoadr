import Foundation
import SwiftData

@Model
final class UserProfile {
    var username: String
    var credits: Int
    var lastLoginDate: Date?
    var isPremium: Bool

    init(username: String = "Trainer", credits: Int = 1_000, isPremium: Bool = false) {
        self.username = username
        self.credits = credits
        self.lastLoginDate = nil
        self.isPremium = isPremium
    }
}
