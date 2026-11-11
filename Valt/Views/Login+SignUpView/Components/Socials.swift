import SwiftUI

struct Socials: View {
    let title: String
    let isGoogleLoading: Bool
    
    var onGoogleTap: () -> Void
    var onAppleTap: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
//                Rectangle()
//                    .fill(Color("TextColor").opacity(0.12))
//                    .frame(height: 1)
                
                Text(title)
                    .foregroundColor(Color("TextColor"))
                    .font(.custom("OpenSans-Regular", size: 14))
                
//                Rectangle()
//                    .fill(Color("TextColor").opacity(0.12))
//                    .frame(height: 1)
            }
            .padding(.top, 10)
            
            HStack(spacing: 14) {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                    onGoogleTap()
                } label: {
                    HStack(spacing: 8) {
                        if isGoogleLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("TextColor")))
                                .scaleEffect(0.85)
                        } else {
                            Image("Google")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Google")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color("BubbleColor"))
                    )
                }
                .buttonStyle(.plain)
                
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                    onAppleTap()
                } label: {
                    HStack(spacing: 8) {
                        Image("appleIcon")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color("TextColor"))
                        Text("Apple")
                            .font(.custom("OpenSans-SemiBold", size: 15))
                            .foregroundColor(Color("TextColor"))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color("BubbleColor"))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
