import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @State private var purchaseManager = PurchaseManager()
    @State private var showPaywall = false
    @AppStorage("companyName") private var companyName = ""
    @AppStorage("tagline") private var tagline = ""
    @AppStorage("primaryColorHex") private var primaryColorHex = "2563EB"

    var body: some View {
        NavigationStack {
            List {
                proSection
                brandSection
                supportSection
                aboutSection
                legalSection
            }
            .navigationTitle("Settings")
        }
    }

    private var proSection: some View {
        Section {
            if purchaseManager.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(AppConstants.Colors.warning)
                    Text("Pro Active")
                        .fontWeight(.medium)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(AppConstants.Colors.warning)
                        Text("Upgrade to Pro")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                Task {
                    await purchaseManager.restorePurchases()
                }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.uturn.down")
            }
        } header: {
            Text("Subscription")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
    }

    private var brandSection: some View {
        Section {
            NavigationLink {
                BrandSettingsView()
            } label: {
                Label("Brand Settings", systemImage: "paintbrush")
            }
        } header: {
            Text("Customization")
        }
    }

    private var supportSection: some View {
        Section {
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
        } header: {
            Text("Support")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: AppConstants.URLs.privacy)!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: AppConstants.URLs.terms)!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
            Link(destination: URL(string: AppConstants.URLs.support)!) {
                Label("Support Page", systemImage: "questionmark.circle")
            }
        } header: {
            Text("Legal")
        }
    }
}

struct BrandSettingsView: View {
    @AppStorage("companyName") private var companyName = ""
    @AppStorage("tagline") private var tagline = ""
    @AppStorage("primaryColorHex") private var primaryColorHex = "2563EB"

    private let colorPresets = [
        ("Blue", "2563EB"),
        ("Indigo", "4F46E5"),
        ("Purple", "7C3AED"),
        ("Rose", "E11D48"),
        ("Orange", "EA580C"),
        ("Green", "059669"),
        ("Teal", "0D9488"),
        ("Slate", "475569"),
    ]

    var body: some View {
        Form {
            Section("Company") {
                TextField("Company Name", text: $companyName)
                TextField("Tagline", text: $tagline)
            }

            Section("Primary Color") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(colorPresets, id: \.1) { name, hex in
                            Button {
                                primaryColorHex = hex
                            } label: {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            if primaryColorHex == hex {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.white)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                    Text(name)
                                        .font(.caption2)
                                        .foregroundStyle(primaryColorHex == hex ? Color(hex: hex) : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                HStack {
                    Text("Custom Hex")
                    Spacer()
                    TextField("#", text: $primaryColorHex)
                        .font(.subheadline.monospaced())
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }

                previewCard
            }
        }
        .navigationTitle("Brand Settings")
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: primaryColorHex))
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(companyName.isEmpty ? "Your Company" : companyName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: primaryColorHex))
                    Text(tagline.isEmpty ? "Your tagline here" : tagline)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let purchaseManager: PurchaseManager
    @State private var selectedPlan = "yearly"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featureComparison
                    planPicker
                    subscribeButton
                    restoreButton
                    subscriptionDetails
                    legalLinks
                }
                .padding()
                .iPadMaxWidth()
            }
            .navigationTitle("Go Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppConstants.Colors.warning)

            Text("Unlock Pro Features")
                .font(.title2)
                .fontWeight(.bold)

            Text("Unlimited proposals, tracking, branding & more")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var featureComparison: some View {
        VStack(alignment: .leading, spacing: 8) {
            featureRow("Unlimited proposals", isPro: true)
            featureRow("Proposal tracking", isPro: true)
            featureRow("Custom branding", isPro: true)
            featureRow("Unlimited templates", isPro: true)
            featureRow("Unlimited pricing rows", isPro: true)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func featureRow(_ text: String, isPro: Bool) -> some View {
        HStack {
            Image(systemName: isPro ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isPro ? AppConstants.Colors.secondary : .secondary)
            Text(text)
                .font(.subheadline)
        }
    }

    private var planPicker: some View {
        HStack(spacing: 12) {
            planCard("Monthly", price: purchaseManager.monthlyProduct?.displayPrice ?? "$9.99", id: "monthly")
            planCard("Yearly", price: purchaseManager.yearlyProduct?.displayPrice ?? "$79.99", id: "yearly", badge: "33% OFF")
            planCard("Lifetime", price: purchaseManager.lifetimeProduct?.displayPrice ?? "$149.99", id: "lifetime", badge: "Best Value")
        }
    }

    private func planCard(_ title: String, price: String, id: String, badge: String? = nil) -> some View {
        Button {
            selectedPlan = id
        } label: {
            VStack(spacing: 6) {
                if let badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppConstants.Colors.secondary)
                        .foregroundStyle(.white)
                        .cornerRadius(4)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(selectedPlan == id ? .bold : .regular)
                Text(price)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedPlan == id ? AppConstants.Colors.primary.opacity(0.1) : Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == id ? AppConstants.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var subscribeButton: some View {
        Button {
            Task {
                let product: Product?
                switch selectedPlan {
                case "monthly": product = purchaseManager.monthlyProduct
                case "yearly": product = purchaseManager.yearlyProduct
                case "lifetime": product = purchaseManager.lifetimeProduct
                default: product = nil
                }
                if let product {
                    _ = await purchaseManager.purchase(product)
                }
            }
        } label: {
            Text("Subscribe Now")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.Colors.primary)
                .foregroundStyle(.white)
                .cornerRadius(12)
        }
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await purchaseManager.restorePurchases()
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var subscriptionDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Subscription Details")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("• Payment will be charged to your Apple ID at confirmation of purchase.")
                Text("• Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                Text("• Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                Text("• You can manage your subscriptions and turn off auto-renewal by going to your Account Settings after purchase.")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
    }

    private var legalLinks: some View {
        VStack(spacing: 8) {
            Link(destination: URL(string: AppConstants.URLs.privacy)!) {
                HStack {
                    Image(systemName: "hand.raised")
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: AppConstants.URLs.terms)!) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Terms of Use (EULA)")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }
}
