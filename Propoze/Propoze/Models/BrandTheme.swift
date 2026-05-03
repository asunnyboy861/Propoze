import Foundation

struct BrandTheme: Codable {
    var id: UUID
    var primaryColorHex: String
    var secondaryColorHex: String
    var accentColorHex: String
    var fontName: String
    var logoData: Data?
    var companyName: String
    var tagline: String

    var primaryColor: String {
        "#\(primaryColorHex)"
    }

    init(
        id: UUID = UUID(),
        primaryColorHex: String = "2563EB",
        secondaryColorHex: String = "10B981",
        accentColorHex: String = "F59E0B",
        fontName: String = "-apple-system",
        logoData: Data? = nil,
        companyName: String = "",
        tagline: String = ""
    ) {
        self.id = id
        self.primaryColorHex = primaryColorHex
        self.secondaryColorHex = secondaryColorHex
        self.accentColorHex = accentColorHex
        self.fontName = fontName
        self.logoData = logoData
        self.companyName = companyName
        self.tagline = tagline
    }
}
