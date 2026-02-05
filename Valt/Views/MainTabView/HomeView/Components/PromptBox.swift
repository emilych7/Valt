import SwiftUI

struct PromptBox: View {
    let prompt: String
    let isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action:
                onTap
        ) {
            HStack(spacing: 15) {
                Text(prompt)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .foregroundColor(Color("TextColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Image("carrotIcon")
                    .resizable()
                    .frame(width: 15, height: 15)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background (
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardColor"))
                    .stroke(Color("TextColor").opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
