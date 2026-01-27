import SwiftUI

@MainActor
struct HomeView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var viewModel: HomeViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    init(userViewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Spacer()
                
                HomeActionButton(icon: viewModel.isFavorited ? "Favorite-Active" : "Favorite-Inactive") {
                    withAnimation { viewModel.isFavorited.toggle() }
                }
                
                HomeActionButton(icon: "saveIcon") {
                    saveAndDismiss()
                }
                .transition(.scale.combined(with: .opacity))
                
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            // Note Editor
            ZStack(alignment: .topLeading) {
                // Color("AppBackgroundColor")
                
                if viewModel.draftText.isEmpty && !isTextFieldFocused {
                    Text("Start your draft here")
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                
                TextEditor(text: $viewModel.draftText)
                    .font(.custom("OpenSans-Regular", size: 16))
                    .foregroundColor(Color("TextColor"))
                    .scrollContentBackground(.hidden)
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
            }
            .padding(.horizontal, 25)
            
            Spacer()
        }
        .background(
            (Color("TextFieldBackground").opacity(0.40))
                .ignoresSafeArea())
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Button("Clear") {
                        viewModel.draftText = ""
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button {
                        isTextFieldFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        saveAndDismiss()
                    }
                    .foregroundColor(Color("TextColor"))
                }
                .font(.custom("OpenSans-Regular", size: 16))
            }
        }
    }
    
    private func saveAndDismiss() {
        if !viewModel.draftText.isEmpty {
            viewModel.saveDraftToFirebase()
            bannerManager.show("Saved Draft")
            isTextFieldFocused = false // Dismiss keyboard
        }
    }
}
