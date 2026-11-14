import SwiftData

extension ChatMessage {
    @MainActor
    static func deleteAll(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<ChatMessage>()
        let all = try context.fetch(descriptor)
        for item in all {
            context.delete(item)
        }
        try context.save()
    }
}
