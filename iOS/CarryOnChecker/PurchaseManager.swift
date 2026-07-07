import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productID = "com.shimondeitel.carryonchecker.pro_unlock"

    @Published var isPro: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { await listenForTransactions() }
        Task { await loadProducts() }
        Task { await refreshEntitlements() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: [Self.productID])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase() async {
        guard let product = products.first else {
            await loadProducts()
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPro = true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                isPro = true
                return
            }
        }
        isPro = false
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }
}
