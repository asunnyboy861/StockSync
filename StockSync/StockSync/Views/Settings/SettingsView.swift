import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var purchaseManager = PurchaseManager()
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            List {
                subscriptionSection
                syncSection
                notificationsSection
                aboutSection
                legalSection
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.loadSettings(purchaseManager: purchaseManager)
            }
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            HStack {
                Text("Current Plan")
                Spacer()
                Text(viewModel.currentTier.rawValue)
                    .foregroundColor(viewModel.currentTier == .free ? .secondary : .blue)
            }

            if viewModel.currentTier == .free {
                Button {
                    showingPaywall = true
                } label: {
                    Label("Upgrade to Pro", systemImage: "crown.fill")
                        .foregroundStyle(.blue)
                }
            }

            Button {
                Task { await purchaseManager.restorePurchases() }
            } label: {
                Text("Restore Purchases")
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
    }

    private var syncSection: some View {
        Section("Sync") {
            Picker("Sync Interval", selection: $viewModel.syncInterval) {
                ForEach(SettingsViewModel.SyncInterval.allCases, id: \.self) { interval in
                    Text(interval.rawValue).tag(interval)
                }
            }
            .onChange(of: viewModel.syncInterval) { _, newValue in
                viewModel.saveSyncInterval(newValue)
            }

            Stepper(
                "Low Stock Threshold: \(viewModel.lowStockThreshold)",
                value: $viewModel.lowStockThreshold,
                in: 1...100
            )
            .onChange(of: viewModel.lowStockThreshold) { _, newValue in
                viewModel.saveLowStockThreshold(newValue)
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                    viewModel.saveNotifications(newValue)
                }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: Constants.appVersion)
            LabeledContent("Build", value: Constants.buildNumber)
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Link("Support", destination: URL(string: Constants.supportURL)!)
            Link("Privacy Policy", destination: URL(string: Constants.privacyURL)!)
            Link("Terms of Use", destination: URL(string: Constants.termsURL)!)
        }
    }
}
