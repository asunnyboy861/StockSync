import SwiftUI
import SwiftData

struct StoresView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = StoresViewModel()
    @State private var showingConnectStore = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.stores) { store in
                    NavigationLink {
                        StoreDetailView(store: store)
                    } label: {
                        StoreRowView(store: store)
                    }
                }
            }
            .overlay {
                if viewModel.stores.isEmpty {
                    ContentUnavailableView(
                        "No Stores Connected",
                        systemImage: "storefront",
                        description: Text("Connect your first store to start syncing inventory")
                    )
                }
            }
            .navigationTitle("Stores")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingConnectStore = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingConnectStore) {
                ConnectStoreView()
            }
            .onAppear {
                viewModel.loadStores(modelContext: modelContext)
            }
        }
    }
}

struct StoreRowView: View {
    let store: Store

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: platformIcon)
                .font(.title2)
                .foregroundStyle(platformColor)
                .frame(width: 40, height: 40)
                .background(platformColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(store.name)
                    .font(.headline)
                Text(store.platform)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(store.isConnected ? Color.green : Color.gray)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }

    private var platformIcon: String {
        switch store.platform {
        case "Shopify": return "bag.fill"
        case "WooCommerce": return "cart.fill"
        case "Etsy": return "hand.raised.fill"
        case "Amazon": return "box.fill"
        default: return "storefront"
        }
    }

    private var platformColor: Color {
        switch store.platform {
        case "Shopify": return .green
        case "WooCommerce": return .purple
        case "Etsy": return .orange
        case "Amazon": return .yellow
        default: return .blue
        }
    }
}

struct StoreDetailView: View {
    @Bindable var store: Store
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = StoresViewModel()

    var body: some View {
        List {
            Section("Store Info") {
                LabeledContent("Name", value: store.name)
                LabeledContent("Platform", value: store.platform)
                LabeledContent("URL", value: store.storeURL)
                LabeledContent("Status", value: store.isConnected ? "Connected" : "Disconnected")
            }

            Section("Connection") {
                LabeledContent("Connected", value: store.connectedAt.formatted(date: .abbreviated, time: .shortened))
                if let lastSync = store.lastSyncAt {
                    LabeledContent("Last Sync", value: lastSync.formatted(date: .abbreviated, time: .shortened))
                }
            }

            Section {
                Button(store.isConnected ? "Disconnect Store" : "Reconnect Store", role: store.isConnected ? .destructive : nil) {
                    viewModel.disconnectStore(store, modelContext: modelContext)
                }
            }
        }
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ConnectStoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = StoresViewModel()
    @State private var selectedPlatform: Store.Platform = .shopify

    @State private var shopifyDomain = ""
    @State private var shopifyToken = ""
    @State private var wooURL = ""
    @State private var wooKey = ""
    @State private var wooSecret = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    platformPicker

                    switch selectedPlatform {
                    case .shopify:
                        shopifyForm
                    case .woocommerce:
                        wooForm
                    case .etsy:
                        comingSoonView("Etsy")
                    case .amazon:
                        comingSoonView("Amazon")
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Connect Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var platformPicker: some View {
        Picker("Platform", selection: $selectedPlatform) {
            ForEach(Store.Platform.allCases, id: \.self) { platform in
                Text(platform.rawValue).tag(platform)
            }
        }
        .pickerStyle(.segmented)
    }

    private var shopifyForm: some View {
        VStack(spacing: 12) {
            TextField("Store domain (e.g. mystore.myshopify.com)", text: $shopifyDomain)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            SecureField("Access Token", text: $shopifyToken)
                .textFieldStyle(.roundedBorder)

            Button {
                Task {
                    await viewModel.connectShopify(
                        storeDomain: shopifyDomain,
                        accessToken: shopifyToken,
                        modelContext: modelContext
                    )
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            } label: {
                if viewModel.isConnecting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Connect Shopify")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(shopifyDomain.isEmpty || shopifyToken.isEmpty || viewModel.isConnecting)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var wooForm: some View {
        VStack(spacing: 12) {
            TextField("Store URL (e.g. https://mystore.com)", text: $wooURL)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            SecureField("Consumer Key", text: $wooKey)
                .textFieldStyle(.roundedBorder)
            SecureField("Consumer Secret", text: $wooSecret)
                .textFieldStyle(.roundedBorder)

            Button {
                Task {
                    await viewModel.connectWooCommerce(
                        storeURL: wooURL,
                        consumerKey: wooKey,
                        consumerSecret: wooSecret,
                        modelContext: modelContext
                    )
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            } label: {
                if viewModel.isConnecting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Connect WooCommerce")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(wooURL.isEmpty || wooKey.isEmpty || wooSecret.isEmpty || viewModel.isConnecting)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func comingSoonView(_ platform: String) -> some View {
        ContentUnavailableView(
            "\(platform) Coming Soon",
            systemImage: "clock.badge.questionmark",
            description: Text("We're working on \(platform) integration. Join the waitlist!")
        )
    }
}
