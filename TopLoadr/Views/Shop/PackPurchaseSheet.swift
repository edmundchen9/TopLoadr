import SwiftData
import SwiftUI

struct PackPurchaseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    let set: PTCGSet
    var credits: CreditsService

    private let api = PokemonTCGAPI()
    private let packer = PackOpeningService()

    @State private var isLoading = false
    @State private var errorText: String?
    @State private var pulled: [PTCGCard] = []

    private var cost: Int {
        credits.currentPackPrice(context: modelContext)
    }

    var body: some View {
        NavigationStack {
            Group {
                if pulled.isEmpty { purchaseView } else { PackOpeningView(cards: pulled) { pulled = [] } }
            }
        .navigationTitle(set.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { _ = credits.ensureProfile(modelContext) }
        .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var purchaseView: some View {
        VStack(alignment: .leading, spacing: 16) {
            PackArtwork()
            if let s = set.series {
                Text(s).font(.subheadline).foregroundStyle(.secondary)
            }
            HStack {
                Text("Set size")
                Spacer()
                Text("\(set.total) cards (catalog)")
            }
            HStack {
                Text("Your price")
                Spacer()
                Text("\(cost) credits")
                    .fontWeight(.semibold)
            }
            if let c = profiles.first?.credits {
                HStack {
                    Text("Your balance")
                    Spacer()
                    Text("\(c) credits")
                }
            }
            if isLoading { ProgressView("Preparing your pack…") }
            if let e = errorText { Text(e).font(.callout).foregroundStyle(.red) }
            Spacer()
            Button {
                Task { await openPack() }
            } label: {
                Text("Open for \(cost) credits")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding(20)
    }

    @MainActor
    private func openPack() async {
        errorText = nil
        isLoading = true
        defer { isLoading = false }
        let packCost = cost
        do {
            let pool = try await api.fetchAllCardsInSet(setId: set.id)
            guard !pool.isEmpty else {
                errorText = "This set returned no cards from the API."
                return
            }
            guard credits.canAfford(packCost, context: modelContext) else {
                errorText = CreditError.insufficient.errorDescription
                return
            }
            try credits.spend(packCost, context: modelContext)
            do {
                let result = try packer.openPack(cards: pool)
                modelContext.addPulledCards(result)
                MissionCoordinator.onPackOpened(modelContext)
                pulled = result
            } catch {
                credits.award(packCost, reason: "refund_pack", context: modelContext, allowPremiumBonus: false)
                errorText = (error as? LocalizedError)?.errorDescription ?? "Could not generate pack."
            }
        } catch {
            errorText = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
    }
}
