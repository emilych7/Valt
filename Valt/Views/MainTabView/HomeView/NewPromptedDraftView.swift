import SwiftUI

struct NewPromptedDraftView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject var tabManager: TabManager
    @FocusState private var isTextFieldFocused: Bool
    
    let selectedPrompt: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HomeActionButton(icon: "exitDynamicIcon", backgroundColor: "ValtRed") {
                    dismiss()
                    viewModel.draftText = ""
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
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(selectedPrompt)
                        .font(.custom("OpenSans-SemiBold", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.8))
                        .multilineTextAlignment(.leading)
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
                    .disabled(viewModel.draftText.isEmpty)
                }
                .font(.custom("OpenSans-Regular", size: 16))
            }
        }
    }
    
//    private func saveAndDismiss() {
//        viewModel.prompt = selectedPrompt
//        viewModel.savePromptedDraftToFirebase()
//        isTextFieldFocused = false
//        dismiss()
//    }
    
    func saveAndDismiss() {
        if !viewModel.draftText.isEmpty {
            viewModel.prompt = selectedPrompt
            viewModel.savePromptedDraftToFirebase()
            isTextFieldFocused = false
            dismiss()
            bannerManager.show("Saved Draft!")
        } else if !viewModel.draftText.isEmpty {
            bannerManager.show("Nothing to save...")
            isTextFieldFocused = false
        }
    }
}
