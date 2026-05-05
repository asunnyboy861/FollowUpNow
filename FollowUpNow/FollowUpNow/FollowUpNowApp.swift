import SwiftUI
import SwiftData

@main
struct FollowUpNowApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .modelContainer(for: [Client.self, FollowUp.self, Interaction.self, FollowUpTemplate.self])
    }
}
