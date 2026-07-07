import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accent)
                    Text("Symbol Search")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Search recurring symbols and tags across every dream entry.")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text(purchases.product != nil ? "Unlock for \(purchases.product!.displayPrice)" : "Unlock $3.99")
                            .font(Theme.bodyFont.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityIdentifier("purchaseButton")
                    .padding(.horizontal)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("paywallRestoreButton")
                    .foregroundStyle(Theme.textSecondary)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("paywallCloseButton")
                }
            }
        }
    }
}

#Preview {
    PaywallView().environmentObject(PurchaseManager())
}
