import SwiftUI
import CoreMotion

final class DeviceTiltManager: ObservableObject {
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0

    #if !targetEnvironment(simulator)
    private let motion = CMMotionManager()
    #endif

    init() {
        #if !targetEnvironment(simulator)
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        #endif
    }

    func start() {
        #if !targetEnvironment(simulator)
        guard motion.isDeviceMotionAvailable, !motion.isDeviceMotionActive else { return }

        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }

            let gx = data.gravity.x
            let gy = data.gravity.y

            let targetRoll = max(min(gx * 22.0, 20.0), -20.0)
            let targetPitch = max(min((gy + 0.72) * 22.0, 20.0), -20.0)

            withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.82)) {
                self.roll = targetRoll
                self.pitch = targetPitch
            }
        }
        #endif
    }

    func stop() {
        #if !targetEnvironment(simulator)
        motion.stopDeviceMotionUpdates()
        #endif
    }
}

struct ValtTiltCardsView: View {
    var size: CGFloat = 205
    var isActive: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var tiltManager = DeviceTiltManager()
    @State private var dragOffset: CGSize = .zero
    @State private var ambientPhase: Double = 0.0

    private var scale: CGFloat {
        size / 205.0
    }

    private var cardWidth: CGFloat { 62.0 * scale }
    private var cardHeight: CGFloat { 80.0 * scale }
    private var gap: CGFloat { 8.0 * scale }

    private var effectiveRoll: Double {
        if reduceMotion { return 0.0 }
        let manual = Double(dragOffset.width / 12.0)
        let ambient = sin(ambientPhase) * 1.8
        let combined = tiltManager.roll + manual + ambient
        return max(min(combined, 22.0), -22.0)
    }

    private var effectivePitch: Double {
        if reduceMotion { return 0.0 }
        let manual = Double(-dragOffset.height / 12.0)
        let ambient = cos(ambientPhase * 0.8) * 1.5
        let combined = tiltManager.pitch + manual + ambient
        return max(min(combined, 22.0), -22.0)
    }

    var body: some View {
        ZStack {
            cardsGrid
        }
        .frame(width: (cardWidth * 3 + gap * 2) + 20 * scale, height: (cardHeight * 2 + gap) + 20 * scale)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.8)) {
                        dragOffset = value.translation
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        dragOffset = .zero
                    }
                }
        )
        .onAppear {
            if isActive {
                tiltManager.start()
            }
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    ambientPhase = .pi * 2
                }
            }
        }
        .onChange(of: isActive) { active in
            if active {
                tiltManager.start()
            } else {
                tiltManager.stop()
            }
        }
        .onDisappear {
            tiltManager.stop()
        }
    }

    private var cardsGrid: some View {
        VStack(spacing: gap) {
            HStack(spacing: gap) {
                tiltCard(col: 0, row: 0, icon: .prompts, titleRatio: 0.68, lines: [0.85, 0.55])
                tiltCard(col: 1, row: 0, icon: .favorite, titleRatio: 0.80, lines: [0.92, 0.65, 0.40])
                tiltCard(col: 2, row: 0, icon: .publish, titleRatio: 0.60, lines: [0.75, 0.88])
            }

            HStack(spacing: gap) {
                tiltCard(col: 0, row: 1, icon: .favorite, titleRatio: 0.72, lines: [0.90, 0.60])
                tiltCard(col: 1, row: 1, icon: .prompts, titleRatio: 0.82, lines: [0.70, 0.85, 0.48])
                tiltCard(col: 2, row: 1, icon: .publish, titleRatio: 0.65, lines: [0.80, 0.50])
            }
            
            HStack(spacing: gap) {
                tiltCard(col: 0, row: 0, icon: .prompts, titleRatio: 0.68, lines: [0.85, 0.55])
                tiltCard(col: 1, row: 0, icon: .favorite, titleRatio: 0.80, lines: [0.92, 0.65, 0.40])
                tiltCard(col: 2, row: 0, icon: .publish, titleRatio: 0.60, lines: [0.75, 0.88])
            }
        }
        .rotation3DEffect(
            .degrees(effectivePitch),
            axis: (x: -1, y: 0, z: 0),
            perspective: 0.45
        )
        .rotation3DEffect(
            .degrees(effectiveRoll),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.45
        )
    }

    private func tiltCard(
        col: Int,
        row: Int,
        icon: TiltCardIconType,
        titleRatio: CGFloat,
        lines: [CGFloat]
    ) -> some View {
        let parallaxX = CGFloat(effectiveRoll) * CGFloat(col - 1) * 0.45 * scale
        let parallaxY = CGFloat(effectivePitch) * (CGFloat(row) - 0.5) * 0.45 * scale

        return TiltNoteCard(
            width: cardWidth,
            height: cardHeight,
            iconType: icon,
            titleRatio: titleRatio,
            lineRatios: lines,
            roll: effectiveRoll,
            pitch: effectivePitch,
            scale: scale
        )
        .offset(x: parallaxX, y: parallaxY)
    }
}

enum TiltCardIconType {
    case publish
    case favorite
    case prompts
}

struct TiltNoteCard: View {
    let width: CGFloat
    let height: CGFloat
    let iconType: TiltCardIconType
    let titleRatio: CGFloat
    let lineRatios: [CGFloat]
    let roll: Double
    let pitch: Double
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                .fill(Color("CardColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                        .stroke(Color("TextColor").opacity(0.08), lineWidth: 0.8)
                )
                //.overlay(specularSheen)

            VStack(alignment: .leading, spacing: 3 * scale) {
                HStack {
                    Spacer()
                    iconView
                }
                .padding(.top, 4 * scale)
                .padding(.trailing, 4 * scale)

                RoundedRectangle(cornerRadius: 1.5 * scale, style: .continuous)
                    .fill(Color("TextColor").opacity(0.48))
                    .frame(width: width * titleRatio, height: 2.8 * scale)

                ForEach(lineRatios.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1.2 * scale, style: .continuous)
                        .fill(Color("TextColor").opacity(index == 0 ? 0.28 : 0.20))
                        .frame(width: width * lineRatios[index], height: 2.0 * scale)
                }

                Spacer(minLength: 0)

            }
            .padding(.horizontal, 6 * scale)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10 * scale, style: .continuous))
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 7 * scale,
            x: -CGFloat(roll) * 0.4,
            y: -CGFloat(pitch) * 0.4 + 4 * scale
        )
        .shadow(
            color: Color("ValtAccent").opacity(0.04),
            radius: 12 * scale,
            x: 0,
            y: 4 * scale
        )
    }

//    private var specularSheen: some View {
//        LinearGradient(
//            stops: [
//                .init(color: Color.white.opacity(0.0), location: 0.0),
//                .init(color: Color.white.opacity(0.18), location: 0.5),
//                .init(color: Color.white.opacity(0.0), location: 1.0)
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .offset(
//            x: CGFloat(roll) * 1.5 * scale,
//            y: CGFloat(pitch) * 1.5 * scale
//        )
//        .blendMode(.overlay)
//        .allowsHitTesting(false)
//    }

    @ViewBuilder
    private var iconView: some View {
        switch iconType {
        case .publish:
            Image("publishIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 8.5 * scale, height: 8.5 * scale)
        case .favorite:
            Image("favoriteIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 8.5 * scale, height: 8.5 * scale)
        case .prompts:
            Image("promptsIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 8.5 * scale, height: 8.5 * scale)
        }
    }
}
