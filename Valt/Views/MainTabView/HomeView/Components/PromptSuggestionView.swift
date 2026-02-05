import SwiftUI

struct PromptSuggestionView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text("Suggestions")
                        .font(.custom("OpenSans-SemiBold", size: 19))
                        .foregroundColor(Color("TextColor"))
                    
                    if userViewModel.draftCount < 3 {
                        Image("securityIcon")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                }
                Spacer()
                if userViewModel.draftCount >= 3 {
                    gptBadge
                }
            }
            .padding(.vertical, 10)
            
            if userViewModel.draftCount < 3 {
                lockedStateView
            } else {
                unlockedStateView
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            attemptAutoGeneration(count: userViewModel.draftCount)
        }
        .onChange(of: userViewModel.draftCount) { _, newCount in
            if newCount < 3 {
                viewModel.generatedPrompts = []
                viewModel.showPrompts = false
            }
        }
    }
    
    private func attemptAutoGeneration(count: Int) {
        // Only call the API if there is 3 or more drafts and no prompts stored in the array
        // if count >= 3 && viewModel.generatedPrompts.isEmpty && !viewModel.isLoading {
        if count >= 3 && viewModel.isLoading {
            viewModel.generatePromptFromOwnDrafts(with: userViewModel.drafts)
            viewModel.showPrompts = true
        }
    }

    private var lockedStateView: some View {
        VStack(alignment: .leading) {
            Text("Write 3 notes to unlock personalized prompt suggestions. The more you write, the more tailored they become.")
                .font(.custom("OpenSans-Regular", size: 15))
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
            Spacer()
        }
    }

    private var unlockedStateView: some View {
        VStack(alignment: .leading) {
            Text("Get started with personalized prompt suggestions.")
                .font(.custom("OpenSans-Regular", size: 15))
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
            
            if viewModel.showPrompts && !viewModel.isLoading {
                VStack (spacing: 10) {
                    PromptGeneratorContainer(prompts: viewModel.generatedPrompts, viewModel: viewModel)
                }
            } else if viewModel.isLoading {
                SkeletonPromptView()
            }
        }
    }

    private var gptBadge: some View {
        HStack(spacing: 8) {
            Image("promptsIcon")
                .resizable()
                .frame(width: 15, height: 15)
            Text("GPT-4o")
                .foregroundColor(Color("TextColor"))
                .font(.custom("OpenSans-SemiBold", size: 15))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.4))
        )
    }
}
