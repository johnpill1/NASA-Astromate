import SwiftUI


struct COSMOAvatar: View {
    var isThinking: Bool
    @State private var glow = false

    private let cyan = Color(red: 0.22, green: 0.86, blue: 1.0)

    var body: some View {
        ZStack {
            Circle()
                .fill(cyan.opacity(glow ? 0.12 : 0.05))
                .frame(width: 175, height: 175)
                .blur(radius: 18)

            // Antenna
            Capsule()
                .fill(Color.white.opacity(0.75))
                .frame(width: 5, height: 22)
                .offset(y: -83)
            Circle()
                .fill(cyan)
                .frame(width: 10, height: 10)
                .shadow(color: cyan, radius: 8)
                .offset(y: -96)

            // Body
            RoundedRectangle(cornerRadius: 38)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(red: 0.64, green: 0.76, blue: 0.87)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 112, height: 86)
                .overlay(alignment: .top) {
                    Circle()
                        .fill(cyan.opacity(0.9))
                        .frame(width: 17, height: 17)
                        .shadow(color: cyan, radius: 8)
                        .offset(y: 17)
                }
                .offset(y: 54)

            // Head
            RoundedRectangle(cornerRadius: 42)
                .fill(
                    LinearGradient(
                        colors: [.white, Color(red: 0.67, green: 0.79, blue: 0.90)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 158, height: 116)
                .overlay {
                    RoundedRectangle(cornerRadius: 31)
                        .fill(Color(red: 0.015, green: 0.045, blue: 0.09))
                        .frame(width: 130, height: 83)
                        .overlay {
                            HStack(spacing: 28) {
                                eye
                                eye
                            }
                        }
                        .overlay(alignment: .bottom) {
                            Capsule()
                                .fill(cyan)
                                .frame(width: isThinking ? 13 : 25, height: 4)
                                .shadow(color: cyan, radius: 5)
                                .offset(y: -12)
                        }
                }
                .overlay(alignment: .leading) {
                    Capsule().fill(cyan.opacity(0.8))
                        .frame(width: 5, height: 36)
                        .shadow(color: cyan, radius: 6)
                        .offset(x: 2)
                }
                .overlay(alignment: .trailing) {
                    Capsule().fill(cyan.opacity(0.8))
                        .frame(width: 5, height: 36)
                        .shadow(color: cyan, radius: 6)
                        .offset(x: -2)
                }
                .offset(y: -17)
                .shadow(color: .black.opacity(0.25), radius: 14, y: 9)
        }
        .scaleEffect(glow ? 1.02 : 0.98)
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glow)
        .onAppear { glow = true }
        .accessibilityLabel(isThinking ? "COSMO is thinking" : "COSMO, your robot companion")
    }

    private var eye: some View {
        Capsule()
            .fill(cyan)
            .frame(width: 12, height: isThinking ? 12 : 20)
            .shadow(color: cyan, radius: 7)
    }
}
