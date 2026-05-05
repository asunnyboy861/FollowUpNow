import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ContactsView()
                .tabItem {
                    Label("People", systemImage: "person.2.fill")
                }
                .tag(1)

            PipelineView()
                .tabItem {
                    Label("Pipeline", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .onOpenURL { url in
            guard let host = url.host else { return }
            switch host {
            case "home": selectedTab = 0
            case "contacts": selectedTab = 1
            case "pipeline": selectedTab = 2
            case "settings": selectedTab = 3
            default: selectedTab = 0
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Client.self, FollowUp.self, Interaction.self, FollowUpTemplate.self], inMemory: true)
}
