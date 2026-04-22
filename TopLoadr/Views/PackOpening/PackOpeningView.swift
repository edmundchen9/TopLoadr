import SwiftUI

struct PackOpeningView: View {
    let cards: [PTCGCard]
    var onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You pulled \(cards.count) cards!")
                .font(.headline)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(cards) { c in
                        CardRevealView(card: c)
                    }
                }
            }
            Button("Done") { onDone() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    PackOpeningView(
        cards: [],
        onDone: {}
    )
}
