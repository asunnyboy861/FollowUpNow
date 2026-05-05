import StoreKit
import Foundation
import Combine

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isProUnlocked: Bool = false
    @Published var isProPlusUnlocked: Bool = false
    @Published var isLoading: Bool = true

    private let proProductId = "com.zzoutuo.FollowUpNow.pro"
    private let proPlusMonthlyId = "com.zzoutuo.FollowUpNow.proplus.monthly"
    private let proPlusYearlyId = "com.zzoutuo.FollowUpNow.proplus.yearly"

    private var productIds: [String] {
        [proProductId, proPlusMonthlyId, proPlusYearlyId]
    }

    @Published var products: [Product] = []

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchaseStatus()
            isLoading = false
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchaseStatus()
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {}
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchaseStatus()
                    await transaction.finish()
                } catch {}
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchaseStatus() async {
        var hasPro = false
        var hasProPlus = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == proProductId {
                    hasPro = true
                }
                if transaction.productID == proPlusMonthlyId || transaction.productID == proPlusYearlyId {
                    hasProPlus = true
                }
            } catch {}
        }

        isProUnlocked = hasPro || hasProPlus
        isProPlusUnlocked = hasProPlus
    }

    var proProduct: Product? {
        products.first { $0.id == proProductId }
    }

    var proPlusMonthly: Product? {
        products.first { $0.id == proPlusMonthlyId }
    }

    var proPlusYearly: Product? {
        products.first { $0.id == proPlusYearlyId }
    }

    var maxFreeClients: Int { 10 }
    var maxFreeFollowUps: Int { 5 }
    var maxFreeTemplates: Int { 1 }
}

enum StoreError: Error {
    case failedVerification
}
