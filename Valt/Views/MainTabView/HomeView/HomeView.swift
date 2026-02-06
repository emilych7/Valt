import SwiftUI

@MainActor
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject var tabManager: TabManager
    @State private var isNoteShowing = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                MainHeader(title: "Start A Draft", image: "editIcon", action: toggleNewNote)
                    .overlay( Divider()
                        .frame(maxWidth: .infinity, maxHeight:1)
                        .background(Color("TextColor").opacity(0.2)), alignment: .bottom)
                
                PromptSuggestionView(viewModel: viewModel)
                
                Spacer()
            }
            .background(
                ZStack {
                    Color("AppBackgroundColor")
                    Color("TextFieldBackground").opacity(0.7)
                }
                .ignoresSafeArea()
            )
            .onChange(of: userViewModel.drafts) { _, newDrafts in
                viewModel.generatePromptFromOwnDrafts(with: newDrafts)
            }
            .onAppear {
                if !userViewModel.drafts.isEmpty {
                    viewModel.generatePromptFromOwnDrafts(with: userViewModel.drafts)
                }
            }
            .navigationDestination(isPresented: $isNoteShowing) {
                NewDraftView(userViewModel: userViewModel) {
                    self.isNoteShowing = false
                }
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .tabBar)
            }
        }
    }
    
    func toggleNewNote() {
        self.isNoteShowing = !self.isNoteShowing
    }
}
