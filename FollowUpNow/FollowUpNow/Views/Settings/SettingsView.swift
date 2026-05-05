import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @State private var showingPaywall = false
    @State private var showingContactSupport = false
    @State private var notificationEnabled = true
    @State private var privacyMode = false

    var body: some View {
        NavigationStack {
            Form {
                if !purchaseManager.isProUnlocked {
                    upgradeSection
                }

                Section("Subscription Status") {
                    HStack {
                        Text("Current Plan")
                        Spacer()
                        Text(planName)
                            .foregroundStyle(.secondary)
                    }
                    if purchaseManager.isProPlusUnlocked {
                        Button("Manage Subscription") {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    Button("Restore Purchases") {
                        Task {
                            await purchaseManager.restorePurchases()
                        }
                    }
                }

                Section("Notifications") {
                    Toggle("Enable Reminders", isOn: $notificationEnabled)
                    Toggle("Privacy Mode", isOn: $privacyMode)
                }

                Section("Data") {
                    NavigationLink("Templates") {
                        TemplatesView()
                    }
                    Button("Import from Contacts") {
                        importContacts()
                    }
                    Button("Export Data (CSV)") {
                        exportCSV()
                    }
                }

                Section("Legal") {
                    Link("Support", destination: URL(string: "https://asunnyboy861.github.io/FollowUpNow/support.html")!)
                    Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/FollowUpNow/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/FollowUpNow/terms.html")!)
                }

                Section("Contact") {
                    Button("Contact Support") {
                        showingContactSupport = true
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingContactSupport) {
                ContactSupportView()
            }
        }
    }

    private var planName: String {
        if purchaseManager.isProPlusUnlocked {
            return "Pro+"
        } else if purchaseManager.isProUnlocked {
            return "Pro"
        } else {
            return "Free"
        }
    }

    private var upgradeSection: some View {
        Section {
            Button {
                showingPaywall = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.orange)
                    Text("Upgrade to Pro")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func importContacts() {
        Task {
            let service = ContactImportService()
            let granted = await service.requestAccess()
            if granted {
                _ = await service.importContacts(modelContext: modelContext)
            }
        }
    }

    private func exportCSV() {
        let clientsDescriptor = FetchDescriptor<Client>()
        guard let allClients = try? modelContext.fetch(clientsDescriptor) else { return }

        var csv = "First Name,Last Name,Company,Email,Phone,Stage\n"
        for client in allClients {
            let row = [
                client.firstName,
                client.lastName,
                client.company,
                client.email,
                client.phone,
                client.pipelineStage.rawValue
            ].map { "\"\($0.replacingOccurrences(of: "\"", with: "\"\""))\"" }.joined(separator: ",")
            csv += row + "\n"
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("FollowUpNow_Export.csv")
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
