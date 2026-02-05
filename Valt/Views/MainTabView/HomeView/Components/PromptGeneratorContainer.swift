import SwiftUI

struct PromptGeneratorContainer: View {
    let prompts: [String]
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var selectedPrompt: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Group {
                    if viewModel.isLoading {
                        SkeletonPromptView()
                            .transition(.opacity)
                    } else if viewModel.animateItems && !prompts.isEmpty {
                        ForEach(prompts.indices, id: \.self) { index in
                            let prompt = prompts[index]
                            
                            PromptBox(
                                prompt: prompt,
                                isSelected: selectedPrompt == prompt
                            ) {
                                selectedPrompt = prompt
                                viewModel.isPromptSelected = true
                            }
                            .transition(.opacity)
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.4), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.4), value: viewModel.animateItems)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity)
        .navigationDestination(isPresented: $viewModel.isPromptSelected) {
            NewPromptedDraftView(selectedPrompt: selectedPrompt ?? "")
                .environmentObject(userViewModel)
                .environmentObject(viewModel)
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}
