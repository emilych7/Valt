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
    @State private var startTime: Date? = nil

    private var dotDiameter: CGFloat {
        size * 0.30
    }

    var body: some View {
        TimelineView(.animation(paused: !isActive || reduceMotion)) { timeline in
            let referenceDate = startTime ?? timeline.date
            let elapsed = max(0.0, timeline.date.timeIntervalSince(referenceDate))

            let angle: Double = {
                guard isSpinning && !reduceMotion else { return 0.0 }
                switch spinStyle {
                case .continuous:
                    guard spinDuration > 0 else { return 0.0 }
                    let normalized = (elapsed.truncatingRemainder(dividingBy: spinDuration)) / spinDuration
                    return normalized * 360.0
                case .dial:
                    let dialProgress = sin(elapsed * (2.0 * .pi / 2.2))
                    return dialProgress * 20.0
                }
            }()

            let pulseAmount: CGFloat = {
                guard isPulsing && !reduceMotion else { return 0.0 }
                let pulsePeriod = 2.5
                let cycleProgress = (elapsed.truncatingRemainder(dividingBy: pulsePeriod)) / pulsePeriod
                return CGFloat(sin(cycleProgress * 2.0 * .pi - (.pi / 2.0)) * 0.5 + 0.5)
            }()

            ZStack {
                vaultBaseLayer(angle: angle)
                if isPulsing && !reduceMotion {
                    subtlePulsingDotOverlay(pulseAmount: pulseAmount)
                }
            }
            .frame(width: size, height: size)
        }
        .onAppear {
            if startTime == nil {
                startTime = Date()
            }
        }
        .onDisappear {
            startTime = nil
        }
    }

    private func vaultBaseLayer(angle: Double) -> some View {
        Image("launchscreen")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(angle))
    }

    private func subtlePulsingDotOverlay(pulseAmount: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color("ValtRed").opacity(0.18 * pulseAmount + 0.05),
                            Color("ValtRed").opacity(0.06 * pulseAmount + 0.01),
                            Color("ValtRed").opacity(0)
                        ]),
                        center: .center,
                        startRadius: dotDiameter * 0.15,
                        endRadius: dotDiameter * 0.85
                    )
                )
                .frame(width: dotDiameter * 1.7, height: dotDiameter * 1.7)
                .scaleEffect(1.0 + 0.10 * pulseAmount)
                .blur(radius: 4.0 * pulseAmount + 2.0)

            Circle()
                .fill(Color("ValtRed"))
                .frame(width: dotDiameter, height: dotDiameter)
                .blur(radius: 5.0 * pulseAmount + 2.5)
                .opacity(0.28 * pulseAmount + 0.10)
                .scaleEffect(0.98 + 0.06 * pulseAmount)

            Circle()
                .fill(Color("ValtRed"))
                .frame(width: dotDiameter, height: dotDiameter)
                .scaleEffect(0.98 + 0.04 * pulseAmount)
                .shadow(
                    color: Color("ValtRed").opacity(0.35 * pulseAmount + 0.15),
                    radius: 3.5 * pulseAmount + 1.5
                )
        }
        .allowsHitTesting(false)
    }
}
