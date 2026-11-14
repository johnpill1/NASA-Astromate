import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var text: String
    var isFromCosmo: Bool
    var createdAt: Date
    var sentimentScore: Double?

    init(text: String, isFromCosmo: Bool, sentimentScore: Double? = nil) {
        self.id = UUID()
        self.text = text
        self.isFromCosmo = isFromCosmo
        self.createdAt = .now
        self.sentimentScore = sentimentScore
    }
}
