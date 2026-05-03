import SwiftUI
import SwiftData

@main
struct PropozeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Proposal.self, Client.self])
    }
}
