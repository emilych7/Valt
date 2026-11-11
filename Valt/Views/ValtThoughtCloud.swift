import SwiftUI

struct ValtThoughtCloud: View {
    var size: CGFloat = 220
    var isActive: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFloating: Bool = false
    @State private var isSwaying: Bool = false

    var body: some View {
        Image("screen3")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .offset(
                x: reduceMotion ? 0.0 : (isSwaying ? -3.0 : 3.0),
                y: reduceMotion ? 0.0 : (isFloating ? -7.0 : 7.0)
            )
            .rotationEffect(.degrees(reduceMotion ? 0.0 : (isSwaying ? -1.2 : 1.2)))
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                value: isFloating
            )
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                value: isSwaying
            )
            .onAppear {
                startAnimations()
            }
            .onChange(of: isActive) { active in
                if active {
                    startAnimations()
                }
            }
    }

    private func startAnimations() {
        guard !reduceMotion else { return }

        isFloating = false
        isSwaying = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isFloating = true
            isSwaying = true
        }
    }
}
