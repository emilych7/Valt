import SwiftUI

struct PromptSuggestionView: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack (spacing: 8) {
                Text("Suggestions")
                    .font(.custom("OpenSans-SemiBold", size: 19))
                    .foregroundColor(Color("TextColor"))
                
                Image("securityIcon")
                    .resizable( )
                    .frame(width: 15, height: 15)
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 10)
            
            PromptGeneratorContainer(prompts: viewModel.generatedPrompts)
            
            generateButton
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var generateButton: some View {
        Button {
            viewModel.generatePromptFromOwnDrafts()
        } label: {
            HStack(spacing: 10) {
                Text("Regenerate Prompts")
                    .font(.custom("OpenSans-SemiBold", size: 17))
                    .foregroundColor(.white)
                Image("Refresh")
                    .resizable()
                    .frame(width: 15, height: 15)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color("RequestButtonColor"))
            .cornerRadius(12)
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 20)
    }
}
