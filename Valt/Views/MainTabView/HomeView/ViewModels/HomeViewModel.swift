import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var isFavorited = false
    @Published var draftText = ""
    @Published var selectedMoreOption: MoreOption? = nil
    @Published var showMoreOptions: Bool = false
    @Published var bannerManager: BannerManager = BannerManager()
    @Published var draftLoadingState: ContentLoadingState = .complete
    
    private let userViewModel: UserViewModel

    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }

    func saveDraftToFirebase() {
        self.draftLoadingState = .loading
        guard let userID = Auth.auth().currentUser?.uid
            else {
                print("User is not authenticated.")
                self.bannerManager.show("Error")
                return
        }
        guard !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                print("Empty draft. Not saving")
                return
        }
        
        let newDraft = Draft(
            id: UUID().uuidString,
            userID: userID,
            title: String(draftText.prefix(20)),
            content: draftText,
            timestamp: Date(),
            isFavorited: isFavorited,
            isHidden: false,
            isArchived: false,
            isPublished: false,
        )
        
        Task {
            self.draftText = ""
            await userViewModel.addDraft(newDraft)
            self.isFavorited = false
            self.isEditing = false
            self.draftLoadingState = .complete
        }
    }
}
