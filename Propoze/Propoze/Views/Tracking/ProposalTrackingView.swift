import SwiftUI
import MessageUI

struct ProposalTrackingView: View {
    let proposal: Proposal
    @State private var showMailCompose = false
    @State private var showMailAlert = false
    @State private var mailAlertMessage = ""

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
        .sheet(isPresented: $showMailCompose) {
            if MFMailComposeViewController.canSendMail() {
                MailComposeView(
                    to: proposal.clientEmail,
                    subject: "Following up: \(proposal.title)",
                    body: followUpEmailBody,
                    onDismiss: { _ in }
                )
            }
        }
        .alert("Mail Not Available", isPresented: $showMailAlert) {
            Button("OK") {}
        } message: {
            Text(mailAlertMessage)
        }
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

            if proposal.sentAt == nil && proposal.signedAt == nil {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("No activity yet. Mark the proposal as sent to start tracking.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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
            } else if proposal.status == .signed {
                Text("Proposal signed! Congratulations!")
                    .font(.subheadline)
                    .foregroundStyle(AppConstants.Colors.secondary)
            } else if proposal.status == .declined {
                Text("The client declined this proposal. Consider reaching out to discuss alternatives.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    sendFollowUp()
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Reach Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.primary)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
            } else {
                Text("Mark your proposal as sent to start tracking and follow up with the client.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var followUpEmailBody: String {
        """
        Hi \(proposal.clientName),

        I wanted to follow up on the proposal I sent for "\(proposal.title)". 

        Please let me know if you have any questions or if there's anything you'd like to discuss. I'm happy to schedule a call at your convenience.

        Looking forward to hearing from you!

        Best regards
        """
    }

    private func sendFollowUp() {
        if MFMailComposeViewController.canSendMail() {
            showMailCompose = true
        } else {
            mailAlertMessage = "Please set up a Mail account on your device to send follow-up emails."
            showMailAlert = true
        }
    }
}
