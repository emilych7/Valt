import SwiftUI

struct ValtGlisteningNotes: View {
    var size: CGFloat = 220
    var isActive: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShimmering: Bool = false
    @State private var isSparkling: Bool = false

    var body: some View {
        ZStack {
            baseImageView

            if !reduceMotion {
                glistenSweepLayer
                sparklesLayer
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimations()
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimations()
            }
        }
    }

    private var baseImageView: some View {
        Image("screen2")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }

    private var glistenSweepLayer: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: Color.white.opacity(0.12), location: 0.38),
                    .init(color: Color.white.opacity(0.85), location: 0.50),
                    .init(color: Color.white.opacity(0.12), location: 0.62),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: size * 2.2, height: size * 2.2)
            .offset(x: isShimmering ? size * 1.3 : -size * 1.3,
                    y: isShimmering ? size * 1.3 : -size * 1.3)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 2.4).repeatForever(autoreverses: false),
                value: isShimmering
            )
        }
        .frame(width: size, height: size)
        .clipped()
        .mask(
            Image("screen2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        )
        .blendMode(.screen)
        .allowsHitTesting(false)
    }

    private var sparklesLayer: some View {
        ZStack {
            GlistenSparkle(size: size * 0.10, isSparkling: isSparkling)
                .offset(x: -size * 0.28, y: -size * 0.47)

            GlistenSparkle(size: size * 0.11, isSparkling: isSparkling)
                .offset(x: size * 0.44, y: -size * 0.47)

            GlistenSparkle(size: size * 0.10, isSparkling: isSparkling)
                .offset(x: size * 0.44, y: size * 0.45)
        }
        .allowsHitTesting(false)
    }

    private func startAnimations() {
        guard !reduceMotion else { return }

        isShimmering = false
        isSparkling = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isShimmering = true
            isSparkling = true
        }
    }
}

struct GlistenSparkle: View {
    let size: CGFloat
    let isSparkling: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.45, height: size * 0.45)
                .blur(radius: 1.5)

            Capsule()
                .fill(Color.white)
                .frame(width: size, height: size * 0.22)

            Capsule()
                .fill(Color.white)
                .frame(width: size * 0.22, height: size)
        }
        .scaleEffect(isSparkling ? 1.0 : 0.0)
        .opacity(isSparkling ? 0.95 : 0.0)
        .rotationEffect(.degrees(isSparkling ? 45 : 0))
        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isSparkling)
    }
}
