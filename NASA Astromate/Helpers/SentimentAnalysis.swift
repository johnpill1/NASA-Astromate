import NaturalLanguage


enum SentimentAnalyser {
    static func score(_ text: String) -> Double? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        var result: Double?
        let range = text.startIndex..<text.endIndex

        tagger.enumerateTags(
            in: range,
            unit: .paragraph,
            scheme: .sentimentScore,
            options: []
        ) { tag, _ in
            if let tag, let value = Double(tag.rawValue) {
                result = value
            }
            return false
        }
        return result
    }
}
