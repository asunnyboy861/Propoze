import SwiftData
import Foundation

enum ProposalStatus: String, Codable, CaseIterable {
    case draft
    case sent
    case viewed
    case signed
    case declined
    case expired

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .sent: "Sent"
        case .viewed: "Viewed"
        case .signed: "Signed"
        case .declined: "Declined"
        case .expired: "Expired"
        }
    }

    var iconName: String {
        switch self {
        case .draft: "doc"
        case .sent: "paperplane"
        case .viewed: "eye"
        case .signed: "checkmark.seal"
        case .declined: "xmark.circle"
        case .expired: "clock"
        }
    }
}

@Model
final class Proposal {
    var id: UUID
    var title: String
    var clientName: String
    var clientEmail: String
    var clientCompany: String
    var statusRaw: String
    var htmlContent: String
    var createdAt: Date
    var updatedAt: Date
    var sentAt: Date?
    var viewedAt: Date?
    var signedAt: Date?
    var viewCount: Int
    var signatureImage: Data?
    var templateId: UUID?
    var isPro: Bool

    var pricingItems: [PricingItem]

    var status: ProposalStatus {
        get { ProposalStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    var totalAmount: Double {
        pricingItems.reduce(0) { $0 + $1.quantity * $1.unitPrice }
    }

    init(
        id: UUID = UUID(),
        title: String = "",
        clientName: String = "",
        clientEmail: String = "",
        clientCompany: String = "",
        statusRaw: String = ProposalStatus.draft.rawValue,
        htmlContent: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sentAt: Date? = nil,
        viewedAt: Date? = nil,
        signedAt: Date? = nil,
        viewCount: Int = 0,
        signatureImage: Data? = nil,
        templateId: UUID? = nil,
        isPro: Bool = false,
        pricingItems: [PricingItem] = []
    ) {
        self.id = id
        self.title = title
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.clientCompany = clientCompany
        self.statusRaw = statusRaw
        self.htmlContent = htmlContent
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sentAt = sentAt
        self.viewedAt = viewedAt
        self.signedAt = signedAt
        self.viewCount = viewCount
        self.signatureImage = signatureImage
        self.templateId = templateId
        self.isPro = isPro
        self.pricingItems = pricingItems
    }
}
