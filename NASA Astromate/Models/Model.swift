import SwiftData
import Foundation

@Model
class WellbeingResponse {

    var id: UUID
    var date: Date

    var category: String
    var question: String
    var response: String

    var sentimentScore: Double?

    var aiSummary: String?

    init(
        category: String,
        question: String,
        response: String,
        sentimentScore: Double?
    ) {
        self.id = UUID()
        self.date = Date()
        self.category = category
        self.question = question
        self.response = response
        self.sentimentScore = sentimentScore
    }

    // MARK: - Utilities
    @MainActor
    static func deleteAll(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<WellbeingResponse>()
        let all = try context.fetch(descriptor)
        for item in all {
            context.delete(item)
        }
        try context.save()
    }
}
