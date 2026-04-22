import SwiftUI

struct SetListView: View {
    @State private var allSets: [PTCGSet] = []
    @State private var setsByEra: [SetEra: [PTCGSet]] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedSet: PTCGSet?
    @State private var searchText = ""
    @State private var selectedEra: SetEra = .scarletAndViolet

    private let api = PokemonTCGAPI()
    var credits: CreditsService

    private var visibleSets: [PTCGSet] {
        let list = setsByEra[selectedEra] ?? []
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return list }
        return list.filter { set in
            set.name.lowercased().contains(q) || set.id.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            eraTabBar
            List {
                if isLoading, allSets.isEmpty {
                    Section {
                        HStack { ProgressView(); Text("Loading sets…") }
                    }
                }
                if let e = errorMessage, allSets.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Couldn’t load sets")
                            Text(e).font(.caption).foregroundStyle(.secondary)
                            Button("Retry") { Task { await load() } }
                        }
                    }
                }

                if !isLoading, errorMessage == nil {
                    Section {
                        if visibleSets.isEmpty {
                            Text(searchText.isEmpty ? "No sets in this era." : "No matches.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(visibleSets) { s in
                                setRow(s)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search sets")
        .navigationTitle("Booster shop")
        .task { await load() }
        .sheet(item: $selectedSet) { s in
            PackPurchaseSheet(set: s, credits: credits)
        }
    }

    @ViewBuilder
    private func setRow(_ s: PTCGSet) -> some View {
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
                if let se = s.series, !se.isEmpty {
                    Text(se)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Button("Open") { selectedSet = s }
        }
    }

    private var eraTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(SetEra.allCases) { era in
                    let count = setsByEra[era]?.count ?? 0
                    Button {
                        selectedEra = era
                    } label: {
                        Text(era.shortTitle)
                            .font(.subheadline)
                            .fontWeight(selectedEra == era ? .semibold : .regular)
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedEra == era ? Color.purple.opacity(0.2) : Color.secondary.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(era.title), \(count) sets")
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @MainActor
    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            allSets = try await api.fetchSets()
            let grouped = SetEraMapper.groupSetsByEra(allSets)
            setsByEra = grouped
            if let first = SetEra.preferredSelectionOrder.first(where: { !(grouped[$0] ?? []).isEmpty }) {
                selectedEra = first
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
        isLoading = false
    }
}
