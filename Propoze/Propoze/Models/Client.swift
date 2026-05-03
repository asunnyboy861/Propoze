import SwiftData
import Foundation

@Model
final class Client {
    var id: UUID
    var name: String
    var email: String
    var company: String
    var phone: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        company: String = "",
        phone: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.company = company
        self.phone = phone
        self.createdAt = createdAt
    }
}
