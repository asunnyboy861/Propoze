import SwiftUI
import MessageUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var selectedTopic = "General Feedback"
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var showMailCompose = false
    @State private var showMailAlert = false

    private let supportEmail = "iocompile67692@gmail.com"

    private let topics = [
        "General Feedback",
        "Bug Report",
        "Feature Request",
        "Billing Issue",
        "Other"
    ]

    private var canSubmit: Bool {
        !email.isEmpty && email.contains("@") && !message.isEmpty && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            Form {
                topicSection
                contactSection
                messageSection
                submitSection
                emailSection
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert(isSuccess ? "Thank You!" : "Oops", isPresented: $showAlert) {
                Button("OK") {
                    if isSuccess { dismiss() }
                }
            } message: {
                Text(alertMessage)
            }
            .alert("Mail Not Available", isPresented: $showMailAlert) {
                Button("OK") {}
            } message: {
                Text("Please set up a Mail account on your device, or use the in-app form to submit feedback.")
            }
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(
                    to: supportEmail,
                    subject: "[Propoze] \(selectedTopic)",
                    body: mailBody,
                    onDismiss: { result in
                        if result == .sent {
                            isSuccess = true
                            alertMessage = "Thank you for your feedback! We'll get back to you soon."
                            showAlert = true
                        }
                    }
                )
            }
        }
    }

    private var topicSection: some View {
        Section {
            Picker("Topic", selection: $selectedTopic) {
                ForEach(topics, id: \.self) { topic in
                    Text(topic).tag(topic)
                }
            }
        }
    }

    private var contactSection: some View {
        Section {
            TextField("Your Name (Optional)", text: $name)
            TextField("Email Address", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }

    private var messageSection: some View {
        Section {
            TextEditor(text: $message)
                .frame(minHeight: 150)
        } header: {
            Text("Message")
        }
    }

    private var submitSection: some View {
        Section {
            Button {
                Task { await submitFeedback() }
            } label: {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(isSubmitting ? "Submitting..." : "Submit Feedback")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .listRowBackground(AppConstants.Colors.primary)
            .foregroundStyle(.white)
            .disabled(!canSubmit)
        }
    }

    private var emailSection: some View {
        Section {
            Button {
                if MFMailComposeViewController.canSendMail() {
                    showMailCompose = true
                } else {
                    showMailAlert = true
                }
            } label: {
                HStack {
                    Image(systemName: "envelope")
                    Text("Email Us Directly")
                }
            }
        } header: {
            Text("Prefer Email?")
        } footer: {
            Text("You can also reach us at \(supportEmail)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var mailBody: String {
        var body = ""
        if !name.isEmpty { body += "Name: \(name)\n" }
        body += "Email: \(email)\n"
        body += "Topic: \(selectedTopic)\n\n"
        body += message
        return body
    }

    private func submitFeedback() async {
        isSubmitting = true

        let payload: [String: String] = [
            "topic": selectedTopic,
            "name": name,
            "email": email,
            "message": message,
            "app": "Propoze"
        ]

        guard let url = URL(string: AppConstants.URLs.feedbackBackend) else {
            fallbackToMail()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        request.timeoutInterval = 15

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                isSubmitting = false
                isSuccess = true
                alertMessage = "Thank you for your feedback! We'll get back to you soon."
                showAlert = true
            } else {
                fallbackToMail()
            }
        } catch {
            fallbackToMail()
        }
    }

    private func fallbackToMail() {
        isSubmitting = false
        if MFMailComposeViewController.canSendMail() {
            showMailCompose = true
        } else {
            isSuccess = false
            alertMessage = "Could not submit online. Please email us at \(supportEmail) with your feedback."
            showAlert = true
        }
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    let to: String
    let subject: String
    let body: String
    let onDismiss: (MFMailComposeResult) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([to])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: (MFMailComposeResult) -> Void

        init(onDismiss: @escaping (MFMailComposeResult) -> Void) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            onDismiss(result)
            controller.dismiss(animated: true)
        }
    }
}
