import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            onboardingPage(
                title: "Never Lose a Client",
                subtitle: "FollowUpNow keeps track of every follow-up so you never miss an opportunity.",
                image: "handshake.fill",
                color: .blue,
                tag: 0
            )

            onboardingPage(
                title: "Smart Reminders",
                subtitle: "Get timely notifications with quick actions — call, text, snooze, or mark done right from your lock screen.",
                image: "bell.badge.fill",
                color: .orange,
                tag: 1
            )

            onboardingPage(
                title: "AI-Powered Follow-Ups",
                subtitle: "Let AI draft your follow-up messages. Professional, natural, and ready to send in seconds.",
                image: "sparkles",
                color: .purple,
                tag: 2
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private func onboardingPage(title: String, subtitle: String, image: String, color: Color, tag: Int) -> some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: image)
                .font(.system(size: 72))
                .foregroundStyle(color)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                if currentPage < 2 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasCompletedOnboarding = true
                    requestNotifications()
                }
            } label: {
                Text(currentPage < 2 ? "Next" : "Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .tag(tag)
    }

    private func requestNotifications() {
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.setupNotificationCategories()
        }
    }
}
