import SwiftUI

struct GlowingView: View {
    var body: some View {
        ZStack {
                Circle()
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color("ValtRed"))
                    .glow()
            }
        }
    }

struct Glow: ViewModifier {
    @State private var throb = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: throb ? 25 : 5)
                .animation(.easeOut(duration: 0.9).repeatForever(), value: throb)
                .onAppear {
                    throb.toggle()
                }
            content
        }
    }
}

extension View {
    func glow() -> some View {
        modifier(Glow())
    }
}
