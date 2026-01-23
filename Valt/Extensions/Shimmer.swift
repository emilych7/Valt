import SwiftUI

struct Shimmer: ViewModifier {
    @State private var offset: CGFloat = -1.0
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.35),
                            .clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .rotationEffect(.degrees(15))
                    .offset(x: offset * width * 2)
                }
                .clipped()
            }
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    offset = 1.0
                }
            }
    }
}

extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}
