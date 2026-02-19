import SwiftUI

struct FullNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject var tabManager: TabManager
    
    @StateObject private var viewModel: FullNoteViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    init(draft: Draft, userViewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: FullNoteViewModel(userViewModel: userViewModel, draft: draft))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                HomeActionButton(icon: "exitDynamicIcon", backgroundColor: "ValtRed") {
                    dismiss()
                }
                
                Spacer()
                
                HomeActionButton(icon: viewModel.localIsFavorited ? "Favorite-Active" : "Favorite-Inactive") {
                    Task { await viewModel.toggleFavorite() }
                }
                
                HomeActionButton(icon: "saveIcon") {
                    saveAndDismiss()
                }
                .disabled(!viewModel.isDirty)
                .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.isDirty)
                
                HomeActionButton(icon: "moreIcon") {
                    withAnimation { viewModel.showMoreOptions.toggle() }
                }
                .popover(isPresented: $viewModel.showMoreOptions) {
                    moreOptionsPopover
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text(viewModel.formattedDate)
                        .font(.custom("OpenSans-Regular", size: 14))
                        .foregroundColor(Color("TextColor").opacity(0.5))
                    
                    if let promptText = viewModel.draft.prompt {
                        Text(promptText)
                            .font(.custom("OpenSans-SemiBold", size: 16))
                            .foregroundColor(Color("TextColor").opacity(0.8))
                    }
                }
                
                TextEditor(text: $viewModel.editedContent)
                    .font(.custom("OpenSans-Regular", size: 16))
                    .foregroundColor(Color("TextColor"))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
            }
            .padding(.horizontal, 25)

            Spacer()
        }
        .background(Color("CardColor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            tabManager.setTabBarHidden(true)
        }
        .onDisappear {
            tabManager.setTabBarHidden(false)
        }
        .toolbar {
            keyboardToolbarItems
        }
        .alert("Delete Draft?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteDraft()
                    dismiss()
                    bannerManager.show("Draft deleted", backgroundColor: Color("ValtRed"), icon: "trash")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete this draft?")
        }
    }
    
    private var moreOptionsPopover: some View {
        MoreOptionsView(selection: $viewModel.selectedMoreOption, options: viewModel.filteredOptions) { option in
            viewModel.showMoreOptions = false
            
            Task {
                switch option {
                case .publish:
                    await viewModel.updateStatus(field: "isPublished", value: true)
                    isTextFieldFocused = false
                    dismiss()
                    bannerManager.show("Published Draft!", backgroundColor: Color("ValtGreen"), icon: "Publish-Dark")
                    
                case .unpublish:
                    await viewModel.updateStatus(field: "isPublished", value: false)
                    isTextFieldFocused = false
                    dismiss()
                    bannerManager.show("Draft Unpublished", backgroundColor: Color("RequestButtonColor"), icon: "Publish-Dark")
                    
                case .hide:
                    await viewModel.updateStatus(field: "isHidden", value: true)
                    isTextFieldFocused = false
                    dismiss()
                    bannerManager.show("Draft Is Hidden.", backgroundColor: Color("RequestButtonColor"), icon: "Hide-Dark")
                    
                case .delete:
                    viewModel.showDeleteConfirmation = true
                }
            }
        }
        .presentationCompactAdaptation(.popover)
    }

    @ToolbarContentBuilder
    private var keyboardToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            Button("Clear") { viewModel.editedContent = "" }
                .foregroundColor(.red)
        }
        ToolbarItem(placement: .keyboard) {
            Spacer()
        }
        ToolbarItem(placement: .keyboard) {
            Button { isTextFieldFocused = false } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .foregroundColor(Color("TextColor"))
            }
        }
        ToolbarItem(placement: .keyboard) {
            Spacer()
        }
        ToolbarItem(placement: .keyboard) {
            Button("Save") {
                saveAndDismiss()
            }
            .disabled(!viewModel.isDirty)
            .foregroundColor(Color("TextColor"))
        }
    }
    
    func saveAndDismiss() {
        if viewModel.isDirty {
            Task {
                await viewModel.updateDraft()
            }
            isTextFieldFocused = false
            dismiss()
            bannerManager.show("Updated Draft!")
        } else if !viewModel.isDirty {
            bannerManager.show("Nothing to save...")
            isTextFieldFocused = false
        }
    }
}
