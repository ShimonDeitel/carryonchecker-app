import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacing * 2) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.accent)
                Text("Carry-on Checker Pro")
                    .font(Theme.titleFont)
                Text("Unlimited airline presets, multiple bags, and saved comparisons")
                    .font(Theme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer()

                Button {
                    Task {
                        await purchases.purchase()
                        if purchases.isPro { dismiss() }
                    }
                } label: {
                    Text(purchases.products.first?.displayPrice ?? "$4.99")
                        .font(Theme.headlineFont)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }
                .accessibilityIdentifier("paywall.purchaseButton")
                .padding(.horizontal)

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("paywall.restoreButton")
                .font(Theme.captionFont)
            }
            .padding()
            .background(Theme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("paywall.closeButton")
                }
            }
        }
    }
}
