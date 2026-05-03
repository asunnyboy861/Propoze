import Foundation

enum TemplateCategory: String, Codable, CaseIterable {
    case consulting
    case design
    case development
    case marketing
    case general
    case custom

    var displayName: String {
        switch self {
        case .consulting: "Consulting"
        case .design: "Design"
        case .development: "Development"
        case .marketing: "Marketing"
        case .general: "General"
        case .custom: "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .consulting: "briefcase"
        case .design: "paintbrush"
        case .development: "code"
        case .marketing: "megaphone"
        case .general: "doc.text"
        case .custom: "star"
        }
    }
}

struct ProposalTemplate: Identifiable {
    var id: UUID
    var name: String
    var category: TemplateCategory
    var htmlContent: String
    var isBuiltIn: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        category: TemplateCategory = .general,
        htmlContent: String = "",
        isBuiltIn: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.htmlContent = htmlContent
        self.isBuiltIn = isBuiltIn
    }
}
