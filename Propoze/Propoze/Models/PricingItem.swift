import Foundation

struct PricingItem: Codable, Identifiable {
    var id: UUID
    var name: String
    var itemDescription: String
    var quantity: Double
    var unitPrice: Double
    var isOptional: Bool
    var category: String

    var total: Double {
        quantity * unitPrice
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        itemDescription: String = "",
        quantity: Double = 1.0,
        unitPrice: Double = 0.0,
        isOptional: Bool = false,
        category: String = ""
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.isOptional = isOptional
        self.category = category
    }
}
