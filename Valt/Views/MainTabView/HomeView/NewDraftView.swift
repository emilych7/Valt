import SwiftUI

struct NewDraftView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var tabManager: TabManager
    @FocusState private var isTextFieldFocused: Bool
    var isActive: Bool = false
    
    init(userViewModel: UserViewModel, isActive: Bool = false) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
        self.isActive = isActive
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
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
            
            ZStack(alignment: .topLeading) {
                if viewModel.draftText.isEmpty {
                    Text("Start here")
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $viewModel.draftText)
                    .font(.custom("OpenSans-Regular", size: 16))
                    .foregroundColor(Color("TextColor"))
                    .scrollContentBackground(.hidden)
                    .focused($isTextFieldFocused)
            }
            .padding(.horizontal, 25)
            
            Spacer()
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .onAppear {
            isTextFieldFocused = false
        }
        .onChange(of: isActive) { _, newValue in
            isTextFieldFocused = false
            if !newValue {
                tabManager.setTabBarHidden(false)
            }
        }
        .onChange(of: isTextFieldFocused) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                tabManager.setTabBarHidden(newValue)
            }
        }
        .onDisappear {
            tabManager.setTabBarHidden(false)
            isTextFieldFocused = false
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Clear") {
                    viewModel.draftText = ""
                }
                .font(.custom("OpenSans-Regular", size: 16))
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
                    Task {
                        saveAndDismiss()
                    }
                }
                .font(.custom("OpenSans-Regular", size: 16))
                .foregroundColor(Color("TextColor"))
                .disabled(viewModel.draftText.isEmpty)
            }
        }
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
