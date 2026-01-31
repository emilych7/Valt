import SwiftUI

@MainActor
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @State private var isNoteShowing = false
    
    var body: some View {
        VStack(spacing: 10) {
            MainHeader(title: "Start A Draft", image: "editIcon", action: toggleNewNote)
                .overlay( Divider()
                   .frame(maxWidth: .infinity, maxHeight:1)
                   .background(Color("TextColor").opacity(0.2)), alignment: .bottom)
            
            PromptSuggestionView(viewModel: viewModel)
            
            Spacer()
        }
        .background(Color("TextFieldBackground").opacity(0.7))
        .onAppear {
            // Only tries to generate if needed
            viewModel.generatePromptFromOwnDrafts(with: userViewModel.drafts)
            }
        .onChange(of: userViewModel.drafts) { _, newDrafts in
            // No generation if user has less than 3 drafts
            viewModel.generatePromptFromOwnDrafts(with: newDrafts)
        }
        .fullScreenCover(isPresented: $isNoteShowing) {
            NewDraftView(userViewModel: userViewModel) {
                self.isNoteShowing = false
            }
        }
    }
    
    func toggleNewNote() {
        self.isNoteShowing = !self.isNoteShowing
    }
}
