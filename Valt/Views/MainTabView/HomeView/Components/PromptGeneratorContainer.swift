import SwiftUI

struct PromptGeneratorContainer: View {
    let prompts: [String]
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var animateItems = false
    @State private var selectedPrompt: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 15) {
                    if animateItems && !prompts.isEmpty {
                        ForEach(prompts.indices, id: \.self) { index in
                            let prompt = prompts[index]
                            
                            PromptBox(
                                prompt: prompt,
                                isSelected: selectedPrompt == prompt
                            ) {
                                selectedPrompt = (selectedPrompt == prompt) ? nil : prompt
                                viewModel.isPromptSelected = true
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                if !viewModel.isLoading {
                    regenerateButton
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        // Pinned button
//        .safeAreaInset(edge: .bottom) {
//            VStack(spacing: 10) {
//                if let _ = selectedPrompt, !viewModel.isLoading {
//                    WriteButton {
//                        viewModel.isPromptSelected = true
//                    }
//                    .transition(.asymmetric(
//                        insertion: .scale(scale: 0.9),
//                        removal: .scale(scale: 0.8).combined(with: .opacity)
//                    ))
//                }
//            }
//            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedPrompt)
//            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isLoading)
//        }
//        .frame(maxWidth: .infinity)
        .onChange(of: prompts) { _, newValue in
            handleAnimation(for: newValue)
       }
      .onAppear {
          handleAnimation(for: prompts)
       }
        .fullScreenCover(isPresented: $viewModel.isPromptSelected) {
            NewPromptedDraftView(selectedPrompt: selectedPrompt ?? "")
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
    
    private var regenerateButton: some View {
        Button {
            viewModel.refreshPrompts(with: userViewModel.drafts)
        } label: {
            HStack(spacing: 10) {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Regenerate Prompts")
                        .font(.custom("OpenSans-SemiBold", size: 17))
                        .foregroundColor(Color("TextColor"))
                    Image("Refresh")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color("BubbleColor"))
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
    }
}
