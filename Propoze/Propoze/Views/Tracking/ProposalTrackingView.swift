import SwiftUI

struct ProposalTrackingView: View {
    let proposal: Proposal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                activityTimeline
                followUpSection
            }
            .padding()
            .iPadMaxWidth()
        }
        .navigationTitle("Tracking")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(proposal.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(proposal.clientName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            StatusBadge(status: proposal.status)
        }
    }

    private var activityTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Timeline")
                .font(.headline)

            if let sentAt = proposal.sentAt {
                timelineItem(icon: "paperplane", title: "Sent", date: sentAt, color: AppConstants.Colors.primary)
            }

            if let viewedAt = proposal.viewedAt {
                timelineItem(icon: "eye", title: "Opened", date: viewedAt, color: AppConstants.Colors.warning)
            }

            if proposal.viewCount > 0 {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text("Viewed \(proposal.viewCount) time\(proposal.viewCount == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let signedAt = proposal.signedAt {
                timelineItem(icon: "checkmark.seal", title: "Signed", date: signedAt, color: AppConstants.Colors.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func timelineItem(icon: String, title: String, date: Date, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(date.formattedShort)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var followUpSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Follow Up")
                .font(.headline)

            if proposal.status == .viewed {
                Text("Client viewed your proposal. Great time to follow up!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    sendFollowUp()
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Send Follow-Up Email")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.primary)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
            } else if proposal.status == .sent {
                Text("Proposal sent but not yet viewed. Consider following up in 2-3 days.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if proposal.status == .signed {
                Text("Proposal signed! Congratulations!")
                    .font(.subheadline)
                    .foregroundStyle(AppConstants.Colors.secondary)
            } else {
                Text("No tracking data available yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func sendFollowUp() {}
}
