import SwiftUI

// Shimmer effect
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
                            .white.opacity(0.30),
                            .clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: offset * width * 2)
                    .blendMode(.plusLighter)
                }
                .clipped()
            }
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    offset = 1.0
                }
            }
    }
}

extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}

// Skeleton Card
struct SkeletonCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("TextFieldBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("TextColor").opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.20), radius: 4, x: 0, y: 2)
        }
        .frame(width: 110, height: 155)
        .shadow(color: Color.black.opacity(0.20), radius: 4, x: 0, y: 2)
        .shimmer()
        .redacted(reason: .placeholder)
    }
}

// 3 x 3 Loading Grid

struct CardLoadingView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)
    private let placeholderCount = 9 // 3 columns * 3 rows
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
            ], spacing: 20) {
                ForEach(0..<placeholderCount, id: \.self) { _ in
                    SkeletonCardView()
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
    }
}
