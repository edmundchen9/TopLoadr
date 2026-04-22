import SwiftData
import SwiftUI

@main
struct PokemonCardSimApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(
            for: [UserProfile.self, OwnedCard.self, Mission.self],
            isAutosaveEnabled: true
        )
    }
}
