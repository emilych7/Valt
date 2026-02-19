import SwiftUI

@MainActor
class FullNoteViewModel: ObservableObject {
    // Dependencies
    private let userViewModel: UserViewModel
    let draft: Draft
    
    // UI State
    @Published var editedContent: String
    @Published var localIsFavorited: Bool
    @Published var showMoreOptions = false
    @Published var showDeleteConfirmation = false
    @Published var selectedMoreOption: MoreOption? = nil
    
    var isDirty: Bool {
        editedContent != draft.content
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: draft.timestamp)
    }
    
    var filteredOptions: [MoreOption] {
        MoreOption.allCases.filter { option in
            // Publish/Unpublish
            if option == .publish && draft.isPublished { return false }
            if option == .unpublish && !draft.isPublished { return false }
            
            // Archive/Unarchive
            if option == .archive && draft.isArchived { return false }
            if option == .unarchive && !draft.isArchived { return false }
            
            return true
        }
    }
    
    init(userViewModel: UserViewModel, draft: Draft) {
        self.userViewModel = userViewModel
        self.draft = draft
        self.editedContent = draft.content
        self.localIsFavorited = draft.isFavorited
    }
    
    func toggleFavorite() async {
        localIsFavorited.toggle()
        await userViewModel.updateDraft(
            draftID: draft.id,
            updatedFields: ["isFavorited": localIsFavorited]
        )
    }
    
    func updateDraft() async {
        guard isDirty else { return }
        await userViewModel.updateDraft(
            draftID: draft.id,
            updatedFields: ["content": editedContent, "timestamp": Date()]
        )
    }
    
    func updateStatus(field: String, value: Any) async {
        await userViewModel.updateDraft(draftID: draft.id, updatedFields: [field: value])
    }
    
    func deleteDraft() async {
        await userViewModel.deleteDraft(draftID: draft.id)
    }
}
