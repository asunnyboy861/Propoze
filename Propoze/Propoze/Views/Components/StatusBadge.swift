import SwiftUI

struct StatusBadge: View {
    let status: ProposalStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }

    private var statusColor: Color {
        switch status {
        case .draft: .gray
        case .sent: AppConstants.Colors.primary
        case .viewed: AppConstants.Colors.warning
        case .signed: AppConstants.Colors.secondary
        case .declined: AppConstants.Colors.danger
        case .expired: AppConstants.Colors.danger
        }
    }
}
