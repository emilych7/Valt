import SwiftUI

struct PromptBox: View {
    let prompt: String
    let isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Text(prompt)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .foregroundColor(isSelected ? Color("ReverseTextColor") : Color("TextColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background (
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color("TextColor") : Color("CardColor"))
            )
        }
        .buttonStyle(.plain)
    }
}
