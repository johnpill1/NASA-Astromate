import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromCosmo {
                VStack(alignment: .leading, spacing: 6) {
                    Text("COSMO")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Color.cyan)
                    Text(message.text)
                        .foregroundStyle(.white)
                }
                .padding(14)
                .background(Color(red: 0.08, green: 0.17, blue: 0.29), in: RoundedRectangle(cornerRadius: 18))
                .frame(maxWidth: 300, alignment: .leading)
                Spacer(minLength: 35)
            } else {
                Spacer(minLength: 35)
                VStack(alignment: .trailing, spacing: 6) {
                    Text(message.text)
                        .foregroundStyle(.white)
                    if let score = message.sentimentScore {
                        Text("Sentiment \(score, format: .number.precision(.fractionLength(2)))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .padding(14)
                .background(Color.cyan.opacity(0.17), in: RoundedRectangle(cornerRadius: 18))
                .frame(maxWidth: 300, alignment: .trailing)
            }
        }
    }
}

