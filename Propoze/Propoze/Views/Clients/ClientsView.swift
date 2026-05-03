import SwiftUI
import SwiftData

struct ClientsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.name) private var clients: [Client]
    @State private var searchText = ""
    @State private var showAddClient = false

    private var filteredClients: [Client] {
        if searchText.isEmpty { return clients }
        return clients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.company.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredClients) { client in
                    NavigationLink {
                        ClientDetailView(client: client)
                    } label: {
                        clientRow(client)
                    }
                }
                .onDelete(perform: deleteClients)
            }
            .listStyle(.plain)
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddClient = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView()
            }
            .searchable(text: $searchText, prompt: "Search clients")
        }
    }

    private func clientRow(_ client: Client) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppConstants.Colors.primary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(client.name.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundStyle(AppConstants.Colors.primary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(client.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(client.company)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func deleteClients(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredClients[index])
        }
    }
}

struct ClientDetailView: View {
    @Bindable var client: Client

    var body: some View {
        List {
            Section("Info") {
                LabeledContent("Name", value: client.name)
                LabeledContent("Email", value: client.email)
                LabeledContent("Company", value: client.company)
                LabeledContent("Phone", value: client.phone)
            }
        }
        .navigationTitle(client.name)
    }
}

struct AddClientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var company = ""
    @State private var phone = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                TextField("Company", text: $company)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveClient()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveClient() {
        let client = Client(name: name, email: email, company: company, phone: phone)
        modelContext.insert(client)
        dismiss()
    }
}
