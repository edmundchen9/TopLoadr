import SwiftData
import SwiftUI

struct MissionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Mission.typeRaw) private var missions: [Mission]
    var credits: CreditsService

    @State private var isWatchingAd = false

    var body: some View {
        List {
            if missions.isEmpty {
                ContentUnavailableView("No missions", systemImage: "tray", description: Text("Check back after launching the app again."))
            } else {
                ForEach(missions, id: \.persistentModelID) { m in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(m.displayTitle)
                            .font(.headline)
                        ProgressView(value: Double(min(m.progress, m.target)), total: Double(m.target))
                        HStack {
                            Text("Reward: \(m.creditReward) credits")
                            Spacer()
                            if m.isComplete, !m.isClaimed {
                                Button("Claim") { claim(m) }
                                    .buttonStyle(.borderedProminent)
                            } else if m.isClaimed {
                                Text("Completed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Section {
                Button {
                    isWatchingAd = true
                } label: {
                    HStack {
                        Text("Watch ad (mock)")
                        Spacer()
                        Text("+\(AppConstants.adRewardCredits)")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: { Text("Earn credits") } footer: { Text("This prototype does not load real ads—tap to add credits and progress the ad mission.") }
        }
        .sheet(isPresented: $isWatchingAd) {
            VStack(spacing: 20) {
                Text("Pretend an ad just played")
                    .font(.headline)
                Button("Grant reward") {
                    grantAdReward()
                    isWatchingAd = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .navigationTitle("Missions")
    }

    @MainActor
    private func claim(_ m: Mission) {
        guard m.isComplete, m.claimedAt == nil else { return }
        m.claimedAt = Date()
        credits.award(
            m.creditReward,
            reason: "mission_\(m.kind.rawValue)",
            context: modelContext
        )
    }

    @MainActor
    private func grantAdReward() {
        credits.award(
            AppConstants.adRewardCredits,
            reason: "mock_ad",
            context: modelContext
        )
        MissionCoordinator.onAdWatched(modelContext)
    }
}
