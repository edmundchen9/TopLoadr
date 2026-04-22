import SwiftData
import SwiftUI

struct SetListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var sets: [PTCGSet] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedSet: PTCGSet?
    private let api = PokemonTCGAPI()
    var credits: CreditsService

    var body: some View {
        List {
            if isLoading, sets.isEmpty {
                Section {
                    HStack { ProgressView(); Text("Loading sets…") }
                }
            }
            if let e = errorMessage, sets.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Couldn’t load sets")
                        Text(e).font(.caption).foregroundStyle(.secondary)
                        Button("Retry") { Task { await load() } }
                    }
                }
            }
            ForEach(sets) { s in
                HStack(alignment: .top, spacing: 12) {
                    if let u = s.logoURL {
                        AsyncImage(url: u) { p in
                            p.resizable().scaledToFit()
                        } placeholder: { ProgressView() }
                        .frame(width: 64, height: 36)
                    } else { PackArtwork() }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.name)
                            .font(.headline)
                        if let r = s.releaseDate {
                            Text("Released: \(r)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button("Open") { selectedSet = s }
                }
            }
        }
        .navigationTitle("Booster shop")
        .task { await load() }
        .sheet(item: $selectedSet) { s in
            PackPurchaseSheet(set: s, credits: credits)
        }
    }

    @MainActor
    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            sets = try await api.fetchSets()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
        isLoading = false
    }
}
