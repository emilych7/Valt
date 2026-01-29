import SwiftUI

struct FullNoteView: View {
    let draft: Draft
    
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @Environment(\.dismiss) var dismiss

    @State private var showDeleteConfirmation = false
    @State private var editedContent: String
    
    var onDismiss: () -> Void
    
    init(draft: Draft, onDismiss: @escaping () -> Void) {
        self.draft = draft
        self.onDismiss = onDismiss
        _editedContent = State(initialValue: draft.content)
    }
    
    var isDirty: Bool {
        editedContent != draft.content
    }

    var body: some View {
        VStack {
            DraftIcons(
                userViewModel: userViewModel,
                editedContent: $editedContent,
                showDeleteConfirmation: $showDeleteConfirmation,
                draft: draft,
                isDirty: isDirty,
                onDismiss: onDismiss
            )

            DraftText(
                draft: draft,
                editedContent: $editedContent,
                isTextFieldFocused: $isTextFieldFocused
            )

            Spacer()
        }
        .background(Color("AppBackgroundColor"))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                DraftToolBar(
                    draft: draft,
                    editedContent: $editedContent,
                    isTextFieldFocused: $isTextFieldFocused,
                    userViewModel: userViewModel,
                    onDismiss: { dismiss() }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Delete Draft?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await userViewModel.deleteDraft(draftID: draft.id)
                    dismiss()
                    bannerManager.show("Draft deleted", backgroundColor: Color("ValtRed"), icon: "trash")
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to permanently delete this draft?")
        }
    }
}
