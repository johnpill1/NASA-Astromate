import SwiftUI
import SwiftData

struct ClearChatButton: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showConfirm = false

    var body: some View {
        Button(role: .destructive) {
            showConfirm = true
        } label: {
            Label("Clear Chat", systemImage: "trash")
        }
        .confirmationDialog("Clear all messages?", isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                do {
                    try WellbeingResponse.deleteAll(in: modelContext)
                } catch {
                    // You can replace this with an alert or error handling as needed
                    print("Failed to clear chat: \(error)")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove all previous messages.")
        }
    }
}

#Preview {
    // Preview without actual deletion side-effects
    ClearChatButton()
        .padding()
}
