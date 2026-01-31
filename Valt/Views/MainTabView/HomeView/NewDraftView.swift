import SwiftUI

struct NewDraftView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var viewModel: HomeViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    init(userViewModel: UserViewModel, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        _viewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
    }
    
    var onDismiss: () -> Void
    
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
                
                HomeActionButton(icon: "exitDynamicIcon") {
                    onDismiss()
                }
                
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // Note Editor
            ZStack(alignment: .topLeading) {
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
        .background(Color("AppBackgroundColor"))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Button("Clear") {
                        viewModel.draftText = ""
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button {
                        $isTextFieldFocused.wrappedValue = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        Task {
                            if viewModel.draftText != "" {
                                saveAndDismiss()
                            } else {
                                onDismiss()
                            }
                        }
                    }
                    .foregroundColor(Color("TextColor"))
                }
                .font(.custom("OpenSans-Regular", size: 16))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func saveAndDismiss() {
        if !viewModel.draftText.isEmpty {
            viewModel.saveDraftToFirebase()
            bannerManager.show("Saved Draft")
            isTextFieldFocused = false // Dismiss keyboard
        }
    }
}

