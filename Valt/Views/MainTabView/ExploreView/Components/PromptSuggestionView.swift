import SwiftUI

struct PromptSuggestionView: View {
    @ObservedObject var viewModel: ExploreViewModel
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
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func attemptAutoGeneration(count: Int) {
        let isPlaceholder = viewModel.generatedPrompts.first?.contains("at least 3") ?? true
        
        if count >= 3 && isPlaceholder && !viewModel.isLoading {
            viewModel.generatePromptFromOwnDrafts(with: userViewModel.drafts)
        }
    }

    private var lockedStateView: some View {
        VStack(alignment: .leading) {
            Text("Write 3 notes to unlock personalized prompt suggestions. The more you write, the more tailored they become.")
                .font(.custom("OpenSans-Regular", size: 14))
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
            Spacer()
        }
    }

    private var unlockedStateView: some View {
        VStack {
            PromptGeneratorContainer(prompts: viewModel.generatedPrompts)
            Spacer(minLength: 20)
            regenerateButton
        }
    }

    private var gptBadge: some View {
        HStack(spacing: 8) {
            Image("promptsIcon")
                .resizable()
                .frame(width: 15, height: 15)
            Text("GPT-5")
                .foregroundColor(Color("TextColor"))
                .font(.custom("OpenSans-SemiBold", size: 15))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.purple.opacity(0.3))
        )
    }
    
    private var regenerateButton: some View {
        Button {
            viewModel.generatePromptFromOwnDrafts(with: userViewModel.drafts)
        } label: {
            HStack(spacing: 10) {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Regenerate Prompts")
                        .font(.custom("OpenSans-SemiBold", size: 17))
                        .foregroundColor(.white)
                    Image("Refresh")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color("RequestButtonColor"))
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
        .padding(.bottom, 20)
    }
}
