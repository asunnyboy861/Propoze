import SwiftUI
import SwiftData

struct PricingTableView: View {
    @Bindable var proposal: Proposal
    @Environment(\.dismiss) private var dismiss
    @State private var newItemName = ""
    @State private var newItemDescription = ""
    @State private var newItemQuantity = 1.0
    @State private var newItemPrice = 0.0

    var body: some View {
        NavigationStack {
            Form {
                existingItemsSection
                addItemSection
                totalSection
            }
            .navigationTitle("Pricing Table")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var existingItemsSection: some View {
        Section("Items") {
            if proposal.pricingItems.isEmpty {
                Text("No items yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(proposal.pricingItems.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.subheadline)
                            Text(item.itemDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.total.currencyString)
                            .fontWeight(.medium)
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        proposal.pricingItems.remove(at: index)
                    }
                }
            }
        }
    }

    private var addItemSection: some View {
        Section("Add Item") {
            TextField("Item name", text: $newItemName)
            TextField("Description", text: $newItemDescription)
            HStack {
                Text("Qty")
                TextField("Quantity", value: $newItemQuantity, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Price")
                TextField("Price", value: $newItemPrice, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }

            Button("Add Item") {
                addItem()
            }
            .disabled(newItemName.isEmpty)
        }
    }

    private var totalSection: some View {
        Section {
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

    private func addItem() {
        let item = PricingItem(
            name: newItemName,
            itemDescription: newItemDescription,
            quantity: newItemQuantity,
            unitPrice: newItemPrice
        )
        proposal.pricingItems.append(item)

        newItemName = ""
        newItemDescription = ""
        newItemQuantity = 1.0
        newItemPrice = 0.0
    }
}
