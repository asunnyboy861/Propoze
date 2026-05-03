import SwiftUI

enum AppConstants {
    static let bundlePrefix = "com.zzoutuo.Propoze"
    static let appName = "Propoze"
    static let appSubtitle = "Proposals That Win"

    enum Colors {
        static let primary = Color(hex: "2563EB")
        static let secondary = Color(hex: "10B981")
        static let warning = Color(hex: "F59E0B")
        static let danger = Color(hex: "EF4444")
        static let backgroundLight = Color(hex: "F8FAFC")
        static let backgroundDark = Color(hex: "0F172A")
        static let cardLight = Color.white
        static let cardDark = Color(hex: "1E293B")
        static let textPrimaryLight = Color(hex: "1E293B")
        static let textPrimaryDark = Color(hex: "F1F5F9")
        static let textSecondaryLight = Color(hex: "64748B")
        static let textSecondaryDark = Color(hex: "94A3B8")
    }

    enum IAP {
        static let proMonthly = "com.zzoutuo.Propoze.proMonthly"
        static let proYearly = "com.zzoutuo.Propoze.proYearly"
        static let lifetime = "com.zzoutuo.Propoze.lifetime"
    }

    enum Limits {
        static let freeTemplateCount = 3
        static let freeClientCount = 5
        static let freePricingRows = 3
        static let proAIMonthly = 10
    }

    enum URLs {
        static let support = "https://asunnyboy861.github.io/Propoze/support.html"
        static let privacy = "https://asunnyboy861.github.io/Propoze/privacy.html"
        static let terms = "https://asunnyboy861.github.io/Propoze/terms.html"
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
