import SwiftUI

struct SkeletonPromptView: View {
    @State private var animateItems = false

    var body: some View {
        VStack(spacing: 15) {
            ForEach(0..<5, id: \.self) { index in
                SkeletonPromptBox()
                    .frame(height: 70)
                    .opacity(animateItems ? 1 : 0)
                    .offset(x: animateItems ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateItems)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            animateItems = true
        }
    }
}

struct SkeletonPromptBox: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color("TextFieldBackground"))
            .shimmer()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color("TextColor").opacity(0.2), lineWidth: 1)
            )
    }
}
