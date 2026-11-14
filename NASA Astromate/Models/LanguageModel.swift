import Combine
import FoundationModels

@MainActor
final class CosmoAI: ObservableObject {
    private var session: LanguageModelSession?

    var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    func start() {
        guard isAvailable else { return }
        session = LanguageModelSession(instructions: prompt)
    }

    func reply(to text: String) async throws -> String {
        guard let session else {
            return "I'd love to chat, but the on-device Apple Intelligence model isn't available on this device just now. You can still record your check-in here."
        }
        let response = try await session.respond(to: text)
        return response.content
    }
}
