import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    func iPadMaxWidth() -> some View {
        self.frame(maxWidth: 720).frame(maxWidth: .infinity)
    }
}

extension Date {
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var formattedShort: String {
        self.formatted(date: .abbreviated, time: .shortened)
    }
}

extension Double {
    var currencyString: String {
        String(format: "$%.2f", self)
    }
}
