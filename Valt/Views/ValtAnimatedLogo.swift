import SwiftUI

struct ValtAnimatedLogo: View {
    enum SpinStyle {
        case continuous
        case dial
    }

    var size: CGFloat = 84
    var isSpinning: Bool = false
    var spinStyle: SpinStyle = .continuous
    var spinDuration: Double = 15.0
    var isPulsing: Bool = true
    var isActive: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsePhase: Bool = false
    @State private var rotationAngle: Double = 0.0

    private var dotDiameter: CGFloat {
        size * 0.30
    }

    var body: some View {
        ZStack {
            vaultBaseLayer
            if isPulsing && !reduceMotion {
                pulsingDotOverlay
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
        .onDisappear {
            resetAnimations()
        }
    }

    private var vaultBaseLayer: some View {
        Image("launchscreen")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotationAngle))
    }

    private var pulsingDotOverlay: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color("ValtRed").opacity(pulsePhase ? 0.45 : 0.15),
                            Color("ValtRed").opacity(pulsePhase ? 0.20 : 0.05),
                            Color("ValtRed").opacity(0)
                        ]),
                        center: .center,
                        startRadius: dotDiameter * 0.15,
                        endRadius: dotDiameter * 0.95
                    )
                )
                .frame(width: dotDiameter * 2.2, height: dotDiameter * 2.2)
                .scaleEffect(pulsePhase ? 1.25 : 0.90)
                .blur(radius: pulsePhase ? 10 : 4)

            Circle()
                .fill(Color("ValtRed"))
                .frame(width: dotDiameter, height: dotDiameter)
                .blur(radius: pulsePhase ? 12 : 5)
                .opacity(pulsePhase ? 0.75 : 0.25)
                .scaleEffect(pulsePhase ? 1.15 : 0.95)

            Circle()
                .fill(Color("ValtRed"))
                .frame(width: dotDiameter, height: dotDiameter)
                .scaleEffect(pulsePhase ? 1.05 : 0.97)
                .shadow(
                    color: Color("ValtRed").opacity(pulsePhase ? 0.7 : 0.3),
                    radius: pulsePhase ? 8 : 2
                )
        }
        .allowsHitTesting(false)
    }

    private func startAnimations() {
        guard !reduceMotion else { return }

        rotationAngle = 0.0
        pulsePhase = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if isPulsing {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    pulsePhase = true
                }
            }

            if isSpinning {
                switch spinStyle {
                case .continuous:
                    withAnimation(.linear(duration: spinDuration).repeatForever(autoreverses: false)) {
                        rotationAngle = 360.0
                    }
                case .dial:
                    rotationAngle = -20.0
                    withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                        rotationAngle = 20.0
                    }
                }
            }
        }
    }

    private func resetAnimations() {
        pulsePhase = false
        rotationAngle = 0.0
    }
}
