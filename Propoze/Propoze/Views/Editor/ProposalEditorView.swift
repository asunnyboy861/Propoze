import SwiftUI
import SwiftData

struct ProposalEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var proposal: Proposal
    @Query(sort: \Client.name) private var clients: [Client]
    @State private var showPreview = false
    @State private var showPricing = false
    @State private var showSignature = false
    @State private var showShareSheet = false
    @State private var showClientPicker = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleted = false
    @State private var pdfData: Data?
    @State private var isExporting = false
    @AppStorage("isProUser") private var isProUser = false
    @AppStorage("companyName") private var companyName = ""
    @AppStorage("tagline") private var tagline = ""

    @State private var executiveSummary = ""
    @State private var scopeOfWork = ""
    @State private var nextSteps = ""
    @State private var customSections: [CustomSection] = []
    @State private var showAddSection = false
    @State private var newSectionTitle = ""

    struct CustomSection: Identifiable {
        let id = UUID()
        var title: String
        var content: String
    }

    var body: some View {
        VStack(spacing: 0) {
            editorToolbar

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    proposalHeader
                    clientSection
                    contentSections
                    addSectionButton
                    pricingSection
                    signatureSection
                }
                .padding()
                .iPadMaxWidth()
            }
        }
        .navigationTitle(proposal.title.isEmpty ? "Proposal" : proposal.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showPreview = true
                } label: {
                    Image(systemName: "eye")
                }

                Menu {
                    Button {
                        markAsSent()
                    } label: {
                        Label("Mark as Sent", systemImage: "paperplane")
                    }

                    if isProUser {
                        NavigationLink {
                            ProposalTrackingView(proposal: proposal)
                        } label: {
                            Label("Track Proposal", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    }

                    Button {
                        exportAndSharePDF()
                    } label: {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Proposal", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
        .sheet(isPresented: $showClientPicker) {
            ClientPickerView(clients: clients) { client in
                proposal.clientName = client.name
                proposal.clientEmail = client.email
                proposal.clientCompany = client.company
                proposal.updatedAt = Date()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
        .confirmationDialog("Delete Proposal?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteProposal()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            loadContentFromHTML()
        }
    }

    private var editorToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                toolbarButton("dollarsign.circle", "Pricing") { showPricing = true }
                toolbarButton("pencil.line", "Sign") { showSignature = true }
                toolbarButton("person.2", "Client") { showClientPicker = true }
                Divider().frame(height: 24)
                toolbarButton("eye", "Preview") { showPreview = true }
                toolbarButton("square.and.arrow.up", "Export") { exportAndSharePDF() }
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
            .frame(width: 52, height: 44)
        }
        .buttonStyle(.borderless)
    }

    private var proposalHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Proposal Title", text: $proposal.title)
                .font(.title2)
                .fontWeight(.bold)
                .onChange(of: proposal.title) { _, _ in
                    proposal.updatedAt = Date()
                    rebuildHTML()
                }

            HStack {
                StatusBadge(status: proposal.status)
                Spacer()
                Text(proposal.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var clientSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Client")
                    .font(.headline)

                Spacer()

                if !clients.isEmpty {
                    Button("Choose from list") {
                        showClientPicker = true
                    }
                    .font(.caption)
                }
            }

            TextField("Client Name", text: $proposal.clientName)
                .font(.subheadline)
                .onChange(of: proposal.clientName) { _, _ in rebuildHTML() }
            TextField("Client Email", text: $proposal.clientEmail)
                .font(.subheadline)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .onChange(of: proposal.clientEmail) { _, _ in rebuildHTML() }
            TextField("Company", text: $proposal.clientCompany)
                .font(.subheadline)
                .onChange(of: proposal.clientCompany) { _, _ in rebuildHTML() }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var contentSections: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content")
                .font(.headline)
                .padding(.horizontal)

            sectionCard(
                title: "Executive Summary",
                text: $executiveSummary,
                placeholder: "Briefly describe the purpose and goals of this proposal..."
            )

            sectionCard(
                title: "Scope of Work",
                text: $scopeOfWork,
                placeholder: "Detail the work to be performed, deliverables, and milestones..."
            )

            ForEach($customSections) { $section in
                sectionCardWithDelete(
                    title: section.title,
                    text: $section.content,
                    placeholder: "Enter details for this section...",
                    onDelete: {
                        customSections.removeAll { $0.id == section.id }
                        rebuildHTML()
                    }
                )
            }

            sectionCard(
                title: "Next Steps",
                text: $nextSteps,
                placeholder: "Outline the next steps and timeline for the client..."
            )
        }
    }

    private func sectionCard(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppConstants.Colors.primary)

            TextField(placeholder, text: text, axis: .vertical)
                .font(.body)
                .lineLimit(3...10)
                .onChange(of: text.wrappedValue) { _, _ in rebuildHTML() }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func sectionCardWithDelete(title: String, text: Binding<String>, placeholder: String, onDelete: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppConstants.Colors.primary)

                Spacer()

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            TextField(placeholder, text: text, axis: .vertical)
                .font(.body)
                .lineLimit(3...10)
                .onChange(of: text.wrappedValue) { _, _ in rebuildHTML() }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var addSectionButton: some View {
        Group {
            if showAddSection {
                HStack {
                    TextField("Section Title", text: $newSectionTitle)
                        .font(.subheadline)

                    Button("Add") {
                        guard !newSectionTitle.isEmpty else { return }
                        customSections.append(CustomSection(title: newSectionTitle, content: ""))
                        newSectionTitle = ""
                        showAddSection = false
                        rebuildHTML()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppConstants.Colors.primary)
                    .disabled(newSectionTitle.isEmpty)

                    Button("Cancel") {
                        newSectionTitle = ""
                        showAddSection = false
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            } else {
                Button {
                    showAddSection = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Section")
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppConstants.Colors.primary)
                }
                .padding(.horizontal)
            }
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
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 80)
                        .cornerRadius(8)
                    Spacer()
                    Button("Re-sign") { showSignature = true }
                        .font(.caption)
                }
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

    private func loadContentFromHTML() {
        if proposal.htmlContent.isEmpty {
            executiveSummary = "Thank you for the opportunity to present this proposal. We understand your challenges and are confident our approach will deliver measurable results."
            scopeOfWork = "• Discovery and assessment\n• Strategy development\n• Implementation planning\n• Progress review and optimization"
            nextSteps = "We look forward to partnering with you. Upon agreement, we will begin with a kickoff session within 5 business days."
            rebuildHTML()
        } else {
            parseHTMLToSections(proposal.htmlContent)
        }
    }

    private func parseHTMLToSections(_ html: String) {
        let stripped = stripHTMLTags(html)

        let sections = stripped.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        var foundSummary = false
        var foundScope = false
        var foundNext = false
        var customStartIndex = -1

        for (index, section) in sections.enumerated() {
            let lower = section.lowercased()
            if !foundSummary && (lower.contains("executive summary") || lower.contains("summary")) {
                let content = section.replacingOccurrences(of: "(?i)executive summary\\s*", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty { executiveSummary = content }
                foundSummary = true
            } else if !foundScope && (lower.contains("scope of work") || lower.contains("scope") || lower.contains("deliverables") || lower.contains("technical approach") || lower.contains("project overview")) {
                let content = section.replacingOccurrences(of: "(?i)(scope of work|scope|deliverables|technical approach|project overview)\\s*", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty { scopeOfWork = content }
                foundScope = true
            } else if !foundNext && (lower.contains("next steps") || lower.contains("next step") || lower.contains("why choose")) {
                let content = section.replacingOccurrences(of: "(?i)(next steps?|why choose us)\\s*", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !content.isEmpty { nextSteps = content }
                foundNext = true
            } else if foundSummary && foundScope && !foundNext {
                if customStartIndex == -1 { customStartIndex = index }
            }
        }
    }

    private func stripHTMLTags(_ html: String) -> String {
        var text = html
        text = text.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</p>", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</li>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "<h[1-6][^>]*>", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</h[1-6]>", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func rebuildHTML() {
        var sections = ""

        if !executiveSummary.isEmpty {
            sections += "<h2>Executive Summary</h2><p>\(executiveSummary.htmlEscaped)</p>"
        }

        if !scopeOfWork.isEmpty {
            let items = scopeOfWork.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "^[•\\-\\*]\\s*", with: "", options: .regularExpression) }
                .filter { !$0.isEmpty }
            if items.count > 1 {
                sections += "<h2>Scope of Work</h2><ul>" + items.map { "<li>\($0.htmlEscaped)</li>" }.joined() + "</ul>"
            } else {
                sections += "<h2>Scope of Work</h2><p>\(scopeOfWork.htmlEscaped)</p>"
            }
        }

        for section in customSections {
            if !section.content.isEmpty {
                sections += "<h2>\(section.title.htmlEscaped)</h2><p>\(section.content.htmlEscaped)</p>"
            }
        }

        if !nextSteps.isEmpty {
            sections += "<h2>Next Steps</h2><p>\(nextSteps.htmlEscaped)</p>"
        }

        let html = """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
        <body style="font-family:-apple-system,sans-serif; color:#1a1a1a; padding:40px 24px; line-height:1.6; max-width:800px; margin:0 auto;">
        <div style="text-align:center; margin-bottom:40px;">
        <h1 style="color:#2563EB; margin:0;">\(proposal.title.htmlEscaped)</h1>
        <p style="color:#64748B; font-size:14px;">Prepared for \(proposal.clientName.htmlEscaped)\(proposal.clientCompany.isEmpty ? "" : " | \(proposal.clientCompany.htmlEscaped)") | \(proposal.createdAt.formatted())</p>
        </div>
        \(sections)
        \(proposal.pricingItems.isEmpty ? "" : "{{PRICING_TABLE}}")
        </body></html>
        """

        proposal.htmlContent = html
        proposal.updatedAt = Date()
    }

    private func markAsSent() {
        proposal.status = .sent
        proposal.sentAt = Date()
        proposal.updatedAt = Date()
    }

    private func exportAndSharePDF() {
        isExporting = true
        Task {
            let rendered = TemplateEngine.render(
                templateContent: proposal.htmlContent.isEmpty
                    ? (TemplateEngine.builtInTemplates().first?.htmlContent ?? "")
                    : proposal.htmlContent,
                proposal: proposal
            )
            let data = await PDFExportService.exportAsync(html: rendered)
            await MainActor.run {
                isExporting = false
                if let data = data {
                    pdfData = data
                    showShareSheet = true
                }
            }
        }
    }

    private func deleteProposal() {
        modelContext.delete(proposal)
        dismiss()
    }
}

extension String {
    var htmlEscaped: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

struct ClientPickerView: View {
    let clients: [Client]
    let onSelect: (Client) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredClients: [Client] {
        if searchText.isEmpty { return clients }
        return clients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.company.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredClients) { client in
                Button {
                    onSelect(client)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(AppConstants.Colors.primary.opacity(0.1))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Text(String(client.name.prefix(1)).uppercased())
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppConstants.Colors.primary)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(client.name)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text(client.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search clients")
            .navigationTitle("Select Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct ProposalPreviewView: View {
    let proposal: Proposal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    previewHeader
                    previewContent
                    previewPricing
                    previewSignature
                }
                .padding()
                .iPadMaxWidth()
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var previewHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(proposal.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(AppConstants.Colors.primary)

            if !proposal.clientName.isEmpty {
                Text("Prepared for \(proposal.clientName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !proposal.clientCompany.isEmpty {
                Text(proposal.clientCompany)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Text(proposal.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var previewContent: some View {
        Group {
            if !proposal.htmlContent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposal Details")
                        .font(.headline)

                    let strippedHTML = stripHTMLTags(proposal.htmlContent)
                    Text(strippedHTML)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    private var previewPricing: some View {
        Group {
            if !proposal.pricingItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Investment")
                        .font(.headline)

                    ForEach(proposal.pricingItems) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.subheadline)
                                if !item.itemDescription.isEmpty {
                                    Text(item.itemDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(item.total.currencyString)
                                .fontWeight(.medium)
                        }
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
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    private var previewSignature: some View {
        Group {
            if let signatureData = proposal.signatureImage,
               let uiImage = UIImage(data: signatureData) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Signature")
                        .font(.headline)

                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 100)
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    private func stripHTMLTags(_ html: String) -> String {
        var text = html
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
