import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var selectedPlan: PlanType = .pro

    enum PlanType {
        case pro
        case proPlusMonthly
        case proPlusYearly
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    planSelector
                    featureComparison
                    purchaseButton
                    restoreButton
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Maybe Later") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Unlock Full Power")
                .font(.title2)
                .fontWeight(.bold)
            Text("Never lose a client again with Pro features")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var planSelector: some View {
        VStack(spacing: 12) {
            planCard(
                type: .pro,
                title: "Pro",
                price: "$14.99",
                period: "one-time",
                badge: "Best Value",
                features: ["Unlimited clients", "AI follow-ups (on-device)", "Unlimited templates", "Notification actions", "Data export"]
            )

            planCard(
                type: .proPlusMonthly,
                title: "Pro+ Monthly",
                price: "$3.99",
                period: "/month",
                badge: nil,
                features: ["All Pro features", "Cloud AI generation", "iCloud sync", "Smart suggestions", "Priority support"]
            )

            planCard(
                type: .proPlusYearly,
                title: "Pro+ Yearly",
                price: "$29.99",
                period: "/year",
                badge: "Save 37%",
                features: ["All Pro+ features", "Best monthly rate", "Priority support"]
            )
        }
    }

    private func planCard(type: PlanType, title: String, price: String, period: String, badge: String?, features: [String]) -> some View {
        Button {
            selectedPlan = type
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(title)
                                .font(.headline)
                            if let badge {
                                Text(badge)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange, in: Capsule())
                                    .foregroundStyle(.white)
                            }
                        }
                        HStack(alignment: .firstTextBaseline) {
                            Text(price)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text(period)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: selectedPlan == type ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(selectedPlan == type ? Color.blue : Color.secondary)
                }

                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .foregroundStyle(.green)
                        Text(feature)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(
                selectedPlan == type ? Color.blue.opacity(0.08) : Color.clear,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == type ? Color.blue : Color.secondary.opacity(0.3), lineWidth: selectedPlan == type ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var featureComparison: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Free plan includes: 10 clients, 5 follow-ups, 1 template")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var purchaseButton: some View {
        Button {
            purchaseSelectedPlan()
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                }
                Text("Subscribe")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .disabled(isPurchasing)
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await purchaseManager.restorePurchases()
                if purchaseManager.isProUnlocked {
                    dismiss()
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private func purchaseSelectedPlan() {
        guard !isPurchasing else { return }
        isPurchasing = true

        Task {
            let product: Product?
            switch selectedPlan {
            case .pro:
                product = purchaseManager.proProduct
            case .proPlusMonthly:
                product = purchaseManager.proPlusMonthly
            case .proPlusYearly:
                product = purchaseManager.proPlusYearly
            }

            if let product {
                let success = await purchaseManager.purchase(product)
                if success {
                    dismiss()
                }
            }
            isPurchasing = false
        }
    }
}
