import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Proposals", systemImage: "doc.text")
                }
                .tag(0)

            ClientsView()
                .tabItem {
                    Label("Clients", systemImage: "person.2")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tint(AppConstants.Colors.primary)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Proposal.self, inMemory: true)
}
