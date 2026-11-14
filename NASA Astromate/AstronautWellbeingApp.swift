import SwiftUI
import SwiftData

@main
struct AstronautWellbeingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ChatMessage.self)
    }
}
