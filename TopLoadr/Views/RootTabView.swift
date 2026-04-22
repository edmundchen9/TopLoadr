import SwiftData
import SwiftUI

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var credits = CreditsService()
    @State private var daily = DailyLoginService()
    @State private var showPremium = false

    var body: some View {
        TabView {
            NavigationStack { SetListView(credits: credits) }
                .tabItem { Label("Shop", systemImage: "storefront") }

            NavigationStack { BinderView() }
                .tabItem { Label("Binder", systemImage: "book.closed") }

            NavigationStack { MissionsView(credits: credits) }
                .tabItem { Label("Missions", systemImage: "checkmark.circle") }

            ProfileView(
                showPremium: $showPremium,
                credits: credits
            )
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(.purple)
        .onAppear {
            MissionCoordinator.seedIfEmpty(modelContext)
            daily.checkAndApplyDailyBonus(modelContext, credits: credits)
        }
        .sheet(isPresented: $showPremium) {
            PremiumUpsellSheet(credits: credits)
        }
    }
}

