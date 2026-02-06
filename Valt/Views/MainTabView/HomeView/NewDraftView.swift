import SwiftUI

struct NewDraftView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var tabManager: TabManager
    @FocusState private var isTextFieldFocused: Bool
    
    init(userViewModel: UserViewModel, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        _viewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
    }
    
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HomeActionButton(icon: "exitDynamicIcon", backgroundColor: "ValtRed") {
                    onDismiss()
                }
                
                Spacer()
                
                HomeActionButton(icon: viewModel.isFavorited ? "Favorite-Active" : "Favorite-Inactive") {
                    withAnimation { viewModel.isFavorited.toggle() }
                }
                .disabled(viewModel.draftText.isEmpty)
                
                HomeActionButton(icon: "saveIcon") {
                    saveAndDismiss()
                }
                .transition(.scale.combined(with: .opacity))
                .disabled(viewModel.draftText.isEmpty)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            
            // Note Editor
            ZStack(alignment: .topLeading) {
                if viewModel.draftText.isEmpty {
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
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .onAppear {
            tabManager.setTabBarHidden(true)
            isTextFieldFocused = true
        }
        .onDisappear { tabManager.setTabBarHidden(false) }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Button("Clear") {
                        viewModel.draftText = ""
                    }
                    .foregroundColor(.red)
                    .disabled(viewModel.draftText.isEmpty)
                    
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
                            saveAndDismiss()
                        }
                    }
                    .foregroundColor(Color("TextColor"))
                    .disabled(viewModel.draftText.isEmpty)
                }
                .font(.custom("OpenSans-Regular", size: 16))
            }
        }
        // .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func saveAndDismiss() {
        if !viewModel.draftText.isEmpty {
            viewModel.saveDraftToFirebase()
            isTextFieldFocused = false
            dismiss()
            bannerManager.show("Saved Draft!")
        } else if !viewModel.draftText.isEmpty {
            bannerManager.show("Nothing to save...")
            isTextFieldFocused = false
        }
    }
}

