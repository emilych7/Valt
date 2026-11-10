import SwiftUI

enum ExplorePromptCardStyle {
    case fullWidth
    case compact
    case carousel
}

struct ExplorePromptSuggestionCard: View {
    let prompt: String
    var style: ExplorePromptCardStyle = .fullWidth
    let onTap: () -> Void
    
    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            onTap()
        } label: {
            switch style {
            case .compact:
                compactContent
            case .carousel:
                carouselContent
            case .fullWidth:
                fullWidthContent
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onTap()
            } label: {
                Label("Write to this Prompt", systemImage: "pencil.line")
            }
            
            Button {
                UIPasteboard.general.string = prompt
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } label: {
                Label("Copy Prompt", systemImage: "doc.on.doc")
            }
        }
    }
    
    private var compactContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Image("promptsIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 11)
                
                Text("PROMPT")
                    .font(.custom("OpenSans-Bold", size: 9))
                    .foregroundColor(Color("TextColor").opacity(0.6))
                    .tracking(0.8)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Text("Write")
                        .font(.custom("OpenSans-SemiBold", size: 10))
                    Image(systemName: "pencil")
                        .font(.system(size: 8.5))
                }
                .foregroundColor(Color("ReverseTextColor"))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color("TextColor")))
            }
            
            Text(prompt)
                .font(.custom("OpenSans-SemiBold", size: 12))
                .foregroundColor(Color("TextColor"))
                .lineSpacing(2.5)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .padding(11)
        .frame(maxWidth: .infinity)
        .frame(height: 124)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color("CardColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(Color("TextColor").opacity(0.08), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(0.025),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        )
    }
    
    private var carouselContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image("promptsIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 11)
                
                Text("PROMPT")
                    .font(.custom("OpenSans-Bold", size: 9))
                    .foregroundColor(Color("TextColor").opacity(0.6))
                    .tracking(1)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Text("Write")
                        .font(.custom("OpenSans-SemiBold", size: 10))
                    Image(systemName: "pencil")
                        .font(.system(size: 9))
                }
                .foregroundColor(Color("ReverseTextColor"))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color("TextColor")))
            }
            
            Text(prompt)
                .font(.custom("OpenSans-SemiBold", size: 12.5))
                .foregroundColor(Color("TextColor"))
                .lineSpacing(2.5)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: 230, height: 96)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color("CardColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(Color("TextColor").opacity(0.08), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(0.03),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        )
    }
    
    private var fullWidthContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image("promptsIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                
                Text("SUGGESTED PROMPT")
                    .font(.custom("OpenSans-Bold", size: 10))
                    .foregroundColor(Color("TextColor").opacity(0.6))
                    .tracking(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Write note")
                        .font(.custom("OpenSans-SemiBold", size: 11))
                    Image(systemName: "pencil.line")
                        .font(.system(size: 11))
                }
                .foregroundColor(Color("ReverseTextColor"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color("TextColor")))
            }
            
            Text(prompt)
                .font(.custom("OpenSans-SemiBold", size: 15))
                .foregroundColor(Color("TextColor"))
                .lineSpacing(3.5)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("CardColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color("TextColor").opacity(0.08), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(0.03),
                    radius: 6,
                    x: 0,
                    y: 3
                )
        )
    }
}
