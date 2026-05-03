import SwiftUI
import SwiftData

struct TemplatePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let builtIn = TemplateEngine.builtInTemplates()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(builtIn) { template in
                            templateCard(template)
                        }
                    }
                }
                .padding()
                .iPadMaxWidth()
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func templateCard(_ template: ProposalTemplate) -> some View {
        Button {
            createProposal(from: template)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: template.category.iconName)
                    .font(.title2)
                    .foregroundStyle(AppConstants.Colors.primary)

                Text(template.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(template.category.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func createProposal(from template: ProposalTemplate) {
        let proposal = Proposal()
        proposal.title = "New Proposal"
        proposal.htmlContent = template.htmlContent
        modelContext.insert(proposal)
        dismiss()
    }
}
