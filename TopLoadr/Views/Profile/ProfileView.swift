import SwiftData
import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var owned: [OwnedCard]
    @Binding var showPremium: Bool
    var credits: CreditsService

    @State private var allSets: [PTCGSet] = []
    @State private var setsError: String?
    @State private var search = ""

    private let api = PokemonTCGAPI()

    var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                Section("Trainer") {
                    if let p = profile {
                        HStack { Text("Name"); Spacer(); Text(p.username) }
                        HStack { Text("Credits"); Spacer(); Text("\(p.credits)").monospacedDigit() }
                        HStack { Text("Premium"); Spacer(); Text(p.isPremium ? "On" : "Off").foregroundStyle(p.isPremium ? .green : .secondary) }
                    } else { Text("No profile (loading)…") }
                }
                Section {
                    Button("View premium (mock)") { showPremium = true }
                } footer: { Text("Prototype: toggles a local flag for discounts and bonus rewards—no real purchase.") }
                Section {
                    Button {
                        credits.award(
                            AppConstants.mockIAPCreditBundle,
                            reason: "mock_iap",
                            context: modelContext
                        )
                    } label: {
                        Text("Mock buy \(AppConstants.mockIAPCreditBundle) credits")
                    }
                } header: { Text("IAP (mock)") }
                if let e = setsError { Section { Text(e).font(.caption).foregroundStyle(.red) } }
                Section {
                    if allSets.isEmpty, setsError == nil { ProgressView("Loading set list…") }
                    ForEach(filteredSets) { s in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.name)
                                if let r = s.releaseDate {
                                    Text(r).font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(pctString(for: s))
                                    .font(.caption)
                                    .monospacedDigit()
                                if isMaster(for: s) {
                                    Text("Master")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.green.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                } header: { Text("Set progress") } footer: { Text("Progress = unique cards ÷ catalog total in that set. Data from the Pokémon TCG API.") }
            }
            .navigationTitle("Profile")
        }
        .searchable(text: $search, prompt: "Search a set name")
        .task { await loadSets() }
    }

    private var filteredSets: [PTCGSet] {
        if search.isEmpty { return allSets }
        return allSets.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    @MainActor
    private func loadSets() async {
        do {
            allSets = try await api.fetchSets()
        } catch {
            setsError = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
    }

    private func uniqueOwnedCount(for s: PTCGSet) -> Int {
        Set(owned.filter { $0.setID == s.id }.map { $0.cardID }).count
    }

    private func pctString(for s: PTCGSet) -> String {
        let u = uniqueOwnedCount(for: s)
        let t = max(1, s.total)
        let pct = (Double(u) / Double(t)) * 100.0
        return String(format: "%.0f%% · %d / %d", pct, u, t)
    }

    private func isMaster(for s: PTCGSet) -> Bool {
        uniqueOwnedCount(for: s) >= s.total
    }
}

#Preview { Text("—") }
