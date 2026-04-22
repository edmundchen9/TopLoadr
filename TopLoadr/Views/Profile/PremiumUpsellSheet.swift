import SwiftData
import SwiftUI

struct PremiumUpsellSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var credits: CreditsService

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Premium (prototype)")
                    .font(.title2.bold())
                VStack(alignment: .leading, spacing: 8) {
                    Label("Ad-free in a real app", systemImage: "xmark.icloud")
                    Label("Smaller pack credit cost (mock: −\(AppConstants.premiumPackDiscount) credits per pack)", systemImage: "tag")
                    Label("Bonus 10% on free credit earn events", systemImage: "star")
                }
                .font(.subheadline)
                Spacer()
                Button {
                    credits.setPremium(true, context: modelContext)
                    dismiss()
                } label: {
                    Text("Unlock locally (no charge)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                Button("Not now", role: .cancel) { dismiss() }
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

#Preview { Text("—") }
