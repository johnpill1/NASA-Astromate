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
}
