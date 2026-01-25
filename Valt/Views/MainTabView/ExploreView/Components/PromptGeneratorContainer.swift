import SwiftUI

struct PromptGeneratorContainer: View {
    let prompts: [String]
    @ObservedObject var viewModel: ExploreViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var animateItems = false
    
    var body: some View {
        VStack(spacing: 15) {
            if animateItems && !prompts.isEmpty {
                ForEach(prompts.indices, id: \.self) { index in
                    PromptBox(prompt: prompts[index])
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateItems)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: prompts) { oldValue, newValue in
            animateItems = false
            
            if !newValue.isEmpty && newValue.first != "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation {
                        animateItems = true
                    }
                }
            }
        }
        .onAppear {
            if !prompts.isEmpty && prompts.first != "" {
                withAnimation {
                    animateItems = true
                }
            }
        }
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
