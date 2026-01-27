import SwiftUI

struct PromptGeneratorContainer: View {
    let prompts: [String]
    @ObservedObject var viewModel: ExploreViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var animateItems = false
    @State private var selectedPrompt: String?
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                SkeletonPromptView()
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        if animateItems && !prompts.isEmpty {
                            ForEach(prompts.indices, id: \.self) { index in
                                let prompt = prompts[index]
                                
                                PromptBox(
                                    prompt: prompt,
                                    isSelected: selectedPrompt == prompt
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPrompt = (selectedPrompt == prompt) ? nil : prompt
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        // Pinned button
        .safeAreaInset(edge: .bottom) {
            if selectedPrompt != nil && viewModel.isLoading == false {
                WriteButton {
                    viewModel.isPromptSelected = true
                }
                .padding(.bottom, 5)
                .background(
                    Color("AppBackgroundColor").opacity(0.8)
                        // .blur(radius: 10)
                        .ignoresSafeArea()
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: prompts) { _, newValue in
            handleAnimation(for: newValue)
        }
        .onAppear {
            handleAnimation(for: prompts)
        }
        .fullScreenCover(isPresented: $viewModel.isPromptSelected) {
            PromptNoteView(selectedPrompt: selectedPrompt ?? "")
                .environmentObject(userViewModel)
                .environmentObject(viewModel)
        }
    }
    
    private func handleAnimation(for newValue: [String]) {
        selectedPrompt = nil
        animateItems = false
        
        if !newValue.isEmpty && newValue.first != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation { animateItems = true }
            }
        }
    }
}

struct PromptBox: View {
    let prompt: String
    let isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Text(prompt)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .foregroundColor(isSelected ? Color(.black)  : Color("TextColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background (
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(.white) : Color("TextFieldBackground"))
                
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.white : Color("TextColor").opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: isSelected)
    }
}

struct WriteButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text("Start a Draft")
                    .font(.custom("OpenSans-SemiBold", size: 17))
                    .foregroundColor(.white)
                Image("editIcon")
                    .frame(width: 13, height: 13)
                    .foregroundColor(.white)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color("BubbleColor"))
            .cornerRadius(12)
        }
    }
}
