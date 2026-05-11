import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            icon: "doc.text.fill",
            title: "Create Proposals",
            subtitle: "Choose from professional templates or start from scratch. Customize every detail to match your brand."
        ),
        OnboardingPage(
            icon: "pencil.line",
            title: "Get Signatures",
            subtitle: "Clients sign right on your device with Apple Pencil or finger. No printing or scanning needed."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track & Win",
            subtitle: "Know when your proposal is opened. Follow up at the right time to close more deals."
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageDots

            actionButtons
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 64))
                .foregroundStyle(AppConstants.Colors.primary)
                .frame(height: 80)

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? AppConstants.Colors.primary : Color(.systemGray4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, 20)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                hasCompletedOnboarding = true
            } label: {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.primary)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            if currentPage < pages.count - 1 {
                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
}
