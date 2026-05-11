import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Proposal.updatedAt, order: .reverse) private var proposals: [Proposal]
    @State private var searchText = ""
    @State private var showNewProposal = false
    @State private var showPaywall = false

    private var draftCount: Int { proposals.filter { $0.status == .draft }.count }
    private var sentCount: Int { proposals.filter { $0.status == .sent }.count }
    private var viewedCount: Int { proposals.filter { $0.status == .viewed }.count }
    private var signedCount: Int { proposals.filter { $0.status == .signed }.count }

    private var filteredProposals: [Proposal] {
        if searchText.isEmpty {
            return proposals
        }
        return proposals.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
            || $0.clientName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusCards

                    if !PurchaseManager.isProUser {
                        proBanner
                    }

                    recentProposals
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Propoze")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewProposal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewProposal) {
                TemplatePickerView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(purchaseManager: PurchaseManager())
            }
            .searchable(text: $searchText, prompt: "Search proposals")
        }
    }

    private var statusCards: some View {
        HStack(spacing: 12) {
            StatusCardView(title: "Draft", count: draftCount, icon: "doc", color: .gray)
            StatusCardView(title: "Sent", count: sentCount, icon: "paperplane", color: AppConstants.Colors.primary)
            StatusCardView(title: "Viewed", count: viewedCount, icon: "eye", color: AppConstants.Colors.warning)
            StatusCardView(title: "Signed", count: signedCount, icon: "checkmark.seal", color: AppConstants.Colors.secondary)
        }
    }

    private var proBanner: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(AppConstants.Colors.warning)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock Pro Features")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("Tracking, branding & unlimited rows")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var recentProposals: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.headline)

            if filteredProposals.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(filteredProposals) { proposal in
                        NavigationLink {
                            ProposalEditorView(proposal: proposal)
                        } label: {
                            ProposalRow(proposal: proposal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No proposals yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap + to create your first proposal")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ProposalRow: View {
    let proposal: Proposal

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(proposal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(proposal.clientName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: proposal.status)

                Text(proposal.updatedAt.relativeString)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
