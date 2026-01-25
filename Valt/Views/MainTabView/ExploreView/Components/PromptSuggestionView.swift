import SwiftUI

struct PromptSuggestionView: View {
    @ObservedObject var viewModel: ExploreViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            
            if userViewModel.draftCount < 3 {
                lockedStateView
            } else {
                unlockedStateView
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            attemptAutoGeneration(count: userViewModel.draftCount)
        }
    }
    
    private func attemptAutoGeneration(count: Int) {
        if count >= 3 && !viewModel.showPrompts && !viewModel.isLoading {
            viewModel.generatePromptFromOwnDrafts(with: userViewModel.drafts)
            viewModel.showPrompts = true
        }
    }

    private var headerRow: some View {
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
            
            if viewModel.showPrompts {
                PromptGeneratorContainer(prompts: viewModel.generatedPrompts, viewModel: viewModel)
                
                regenerateButton
            }
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
                .fill(Color.purple.opacity(0.3))
        )
    }
    
    private var regenerateButton: some View {
        Button {
            viewModel.generatePromptFromOwnDrafts(with: userViewModel.drafts)
        } label: {
            buttonContent(text: "Refresh Prompts")
                .background(Color("RequestButtonColor").opacity(0.3))
                .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
        .padding(.vertical, 10)
    }

    private func buttonContent(text: String) -> some View {
        HStack(spacing: 10) {
            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else {
                Text(text)
                    .font(.custom("OpenSans-SemiBold", size: 17))
                    .foregroundColor(.white)
                Image("Refresh")
                    .resizable()
                    .frame(width: 15, height: 15)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}
