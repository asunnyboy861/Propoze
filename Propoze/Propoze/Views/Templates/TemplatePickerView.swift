import SwiftUI
import SwiftData

struct TemplatePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var navigateToEditor = false
    @State private var createdProposal: Proposal?

    private let builtIn = TemplateEngine.builtInTemplates()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(builtIn) { template in
                        templateCard(template)
                    }

                    blankCard
                }
                .padding()
                .iPadMaxWidth()
            }
            .navigationTitle("New Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationDestination(isPresented: $navigateToEditor) {
                if let proposal = createdProposal {
                    ProposalEditorView(proposal: proposal)
                }
            }
        }
    }

    private func templateCard(_ template: ProposalTemplate) -> some View {
        Button {
            createProposal(from: template)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: template.category.iconName)
                    .font(.title2)
                    .foregroundStyle(AppConstants.Colors.primary)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(template.category.displayName)
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

    private var blankCard: some View {
        Button {
            createBlankProposal()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "doc.badge.plus")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Blank Proposal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text("Start from scratch")
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

    private func createProposal(from template: ProposalTemplate) {
        let proposal = Proposal()
        proposal.title = template.name.replacingOccurrences(of: " Proposal", with: "")
        let rendered = TemplateEngine.render(templateContent: template.htmlContent, proposal: proposal)
        proposal.htmlContent = rendered
        proposal.templateId = template.id
        modelContext.insert(proposal)
        createdProposal = proposal
        navigateToEditor = true
    }

    private func createBlankProposal() {
        let proposal = Proposal()
        proposal.title = "New Proposal"
        modelContext.insert(proposal)
        createdProposal = proposal
        navigateToEditor = true
    }
}
