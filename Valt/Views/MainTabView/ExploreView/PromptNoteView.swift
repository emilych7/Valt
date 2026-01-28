import SwiftUI

struct PromptNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject private var viewModel: ExploreViewModel
    
    @FocusState private var isTextFieldFocused: Bool
    
    let selectedPrompt: String
    
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
                
                HomeActionButton(icon: "exitIcon") {
                    dismiss()
                }
                
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            // Note Editor
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(selectedPrompt)
                        .font(.custom("OpenSans-SemiBold", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.7))
                    Spacer()
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
        viewModel.prompt = selectedPrompt
        viewModel.saveDraftToFirebase()
        isTextFieldFocused = false
        dismiss()
    }
}
