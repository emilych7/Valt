import SwiftUI

struct PromptGeneratorContainer: View {
    let prompts: [String]
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(prompts.indices, id: \.self) { index in
                PromptBox(prompt: prompts[index])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PromptBox: View {
    let prompt: String
    @State private var isSelected: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isSelected.toggle()
            }
        } label: {
            HStack {
                Text(prompt)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Toggle Icon
                Image(isSelected ? "checkedIcon" : "uncheckedIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .transition(AnyTransition.opacity.animation(.smooth(duration: 0.2)))
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background (
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("TextFieldBackground"))
                    .stroke(Color("TextColor").opacity(0.20), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
