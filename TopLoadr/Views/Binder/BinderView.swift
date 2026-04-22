import SwiftData
import SwiftUI

struct BinderView: View {
    @Query(sort: \OwnedCard.name) private var allCards: [OwnedCard]
    @State private var setFilter: String = ""

    private var setIDs: [String] {
        let u = Set(allCards.map(\.setID))
        return u.sorted()
    }

    private var setDisplayNames: [String: String] {
        var m: [String: String] = [:]
        for c in allCards { m[c.setID] = c.setName }
        return m
    }

    private var filtered: [OwnedCard] {
        if setFilter.isEmpty { return allCards }
        return allCards.filter { $0.setID == setFilter }
    }

    var pages: [[OwnedCard]] {
        var out: [[OwnedCard]] = []
        var i = 0
        let f = filtered
        while i < f.count {
            let e = min(i + 9, f.count)
            out.append(Array(f[i..<e]))
            i = e
        }
        return out
    }

    @State private var pageIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Set", selection: $setFilter) {
                Text("All sets").tag("")
                ForEach(setIDs, id: \.self) { id in
                    Text(setDisplayNames[id] ?? id).tag(id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: setFilter) { _, _ in pageIndex = 0 }

            if allCards.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No cards yet",
                    systemImage: "rectangle.on.rectangle",
                    description: Text("Open packs in Shop to add cards to your binder.")
                )
            } else if filtered.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No cards in this set",
                    systemImage: "tray",
                    description: Text("Change the filter or open packs in Shop.")
                )
            } else {
                TabView(selection: $pageIndex) {
                    ForEach(pages.indices, id: \.self) { idx in
                        let page = pages[idx]
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 10
                        ) {
                            ForEach(page) { c in
                                NavigationLink {
                                    CardDetailView(card: c)
                                } label: {
                                    CardThumbnail(
                                        imageURL: URL(string: c.smallImageURL),
                                        name: c.name
                                    )
                                }
                            }
                        }
                        .tag(idx)
                    }
                }
                .frame(minHeight: 400)
                .tabViewStyle(.page)
                if pages.count > 1 {
                    Text("Page \(pageIndex + 1) of \(pages.count)")
                        .font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding()
        .navigationTitle("Collection")
    }
}

#Preview { Text("—") }
