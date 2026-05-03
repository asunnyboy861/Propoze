import SwiftUI
import SwiftData

struct ProposalEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var proposal: Proposal
    @State private var html = ""
    @State private var showPreview = false
    @State private var showPricing = false
    @State private var showSignature = false

    var body: some View {
        VStack(spacing: 0) {
            editorToolbar

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    proposalHeader
                    proposalContent
                    pricingSection
                    signatureSection
                }
                .padding()
                .iPadMaxWidth()
            }
        }
        .navigationTitle(proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showPreview = true
                } label: {
                    Image(systemName: "eye")
                }

                Button {
                    markAsSent()
                } label: {
                    Image(systemName: "paperplane")
                }
            }
        }
        .sheet(isPresented: $showPricing) {
            PricingTableView(proposal: proposal)
        }
        .sheet(isPresented: $showSignature) {
            SignatureView { signatureData in
                proposal.signatureImage = signatureData
                proposal.signedAt = Date()
                proposal.status = .signed
                proposal.updatedAt = Date()
            }
        }
        .sheet(isPresented: $showPreview) {
            ProposalPreviewView(proposal: proposal)
        }
    }

    private var editorToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                toolbarButton("bold", "B") {}
                toolbarButton("italic", "I") {}
                toolbarButton("underline", "U") {}
                Divider().frame(height: 24)
                toolbarButton("list.bullet", "List") {}
                toolbarButton("number.list", "Num") {}
                Divider().frame(height: 24)
                toolbarButton("dollarsign.circle", "Pricing") { showPricing = true }
                toolbarButton("pencil.line", "Sign") { showSignature = true }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.secondarySystemBackground))
    }

    private func toolbarButton(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .font(.caption2)
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.borderless)
    }

    private var proposalHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Proposal Title", text: $proposal.title)
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                TextField("Client Name", text: $proposal.clientName)
                    .font(.subheadline)
                TextField("Client Email", text: $proposal.clientEmail)
                    .font(.subheadline)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
        }
    }

    private var proposalContent: some View {
        TextEditor(text: $html)
            .font(.body)
            .frame(minHeight: 300)
            .padding(8)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
            .onAppear {
                if proposal.htmlContent.isEmpty {
                    loadTemplate()
                } else {
                    html = proposal.htmlContent
                }
            }
            .onChange(of: html) { _, newValue in
                proposal.htmlContent = newValue
                proposal.updatedAt = Date()
            }
    }

    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Pricing")
                    .font(.headline)
                Spacer()
                Button("Edit") { showPricing = true }
            }

            if proposal.pricingItems.isEmpty {
                Text("No pricing items")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(proposal.pricingItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text(item.total.currencyString)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }

                Divider()

                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text(proposal.totalAmount.currencyString)
                        .fontWeight(.bold)
                        .foregroundStyle(AppConstants.Colors.primary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var signatureSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Signature")
                .font(.headline)

            if let signatureData = proposal.signatureImage,
               let uiImage = UIImage(data: signatureData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 100)
                    .cornerRadius(8)
            } else {
                Button {
                    showSignature = true
                } label: {
                    HStack {
                        Image(systemName: "pencil.line")
                        Text("Add Signature")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.primary.opacity(0.1))
                    .foregroundStyle(AppConstants.Colors.primary)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func loadTemplate() {
        let templates = TemplateEngine.builtInTemplates()
        if let first = templates.first {
            html = TemplateEngine.render(templateContent: first.htmlContent, proposal: proposal)
            proposal.htmlContent = html
        }
    }

    private func markAsSent() {
        proposal.status = .sent
        proposal.sentAt = Date()
        proposal.updatedAt = Date()
    }
}

struct ProposalPreviewView: View {
    let proposal: Proposal

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(proposal.htmlContent)
                    .padding()
                    .iPadMaxWidth()
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { }
                }
            }
        }
    }
}
