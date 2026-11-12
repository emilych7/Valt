import SwiftUI

struct ValtThoughtCloud: View {
    var size: CGFloat = 205
    var isActive: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startTime: Date? = nil

    var body: some View {
        TimelineView(.animation(paused: !isActive || reduceMotion)) { timeline in
            let referenceDate = startTime ?? timeline.date
            let elapsed = max(0.0, timeline.date.timeIntervalSince(referenceDate))

            let floatY: CGFloat = reduceMotion ? 0.0 : CGFloat(sin(elapsed * 2.0 * .pi / 4.4) * 6.5)
            let swayX: CGFloat = reduceMotion ? 0.0 : CGFloat(cos(elapsed * 2.0 * .pi / 5.8) * 3.2)
            let tiltAngle: Double = reduceMotion ? 0.0 : Double(sin(elapsed * 2.0 * .pi / 5.0) * 1.2)
            let breatheScale: CGFloat = reduceMotion ? 1.0 : CGFloat(1.0 + sin(elapsed * 2.0 * .pi / 4.4) * 0.012)
            let pulseNorm: CGFloat = CGFloat(sin(elapsed * 2.0 * .pi / 4.4) * 0.5 + 0.5)

            ZStack {
                ambientGlow(scale: breatheScale, pulse: pulseNorm, floatY: floatY)

                // groundShadow(floatY: floatY)

                Image("screen3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .scaleEffect(breatheScale)
                    .rotationEffect(.degrees(tiltAngle))
                    .offset(x: swayX, y: floatY)
//                    .shadow(
//                        color: Color("ValtRed").opacity(0.10 + 0.04 * Double(pulseNorm)),
//                        radius: 12,
//                        x: -swayX * 0.3,
//                        y: 6 - floatY * 0.2
//                    )
                    .shadow(
                        color: Color.black.opacity(0.06),
                        radius: 7,
                        x: 0,
                        y: 5
                    )
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

    private func ambientGlow(scale: CGFloat, pulse: CGFloat, floatY: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: Color("ValtRed").opacity(0.10 + 0.04 * Double(pulse)), location: 0.0),
                        .init(color: Color("ValtRed").opacity(0.03), location: 0.45),
                        .init(color: Color.clear, location: 0.85)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.52
                )
            )
            .frame(width: size * 1.1, height: size * 1.1)
            .blur(radius: 20)
            .offset(y: floatY * 0.3)
            .allowsHitTesting(false)
    }

//    private func groundShadow(floatY: CGFloat) -> some View {
//        let normY = Double(floatY / 6.5)
//        return Ellipse()
//            .fill(
//                RadialGradient(
//                    stops: [
//                        .init(color: Color.black.opacity(0.09 - 0.02 * normY), location: 0.0),
//                        .init(color: Color("ValtRed").opacity(0.03 - 0.01 * normY), location: 0.5),
//                        .init(color: Color.clear, location: 1.0)
//                    ],
//                    center: .center,
//                    startRadius: 0,
//                    endRadius: size * 0.32
//                )
//            )
//            .frame(
//                width: size * 0.60 * CGFloat(1.0 - 0.05 * normY),
//                height: 12 * CGFloat(1.0 - 0.08 * normY)
//            )
//            .offset(y: size * 0.46)
//            .blur(radius: max(3.0, CGFloat(4.5 + 1.5 * normY)))
//            .allowsHitTesting(false)
//    }
}
