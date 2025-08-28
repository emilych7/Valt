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
    
    private let userViewModel: UserViewModel

    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
    }

    func saveDraftToFirebase() {
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
            isPrompted: false,
        )
        
        Task {
            // Shared userViewModel
            await userViewModel.addDraft(newDraft)
            self.draftText = ""
            self.isEditing = false
        }
    }
    
    // Helper button
    func button(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Ellipse()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("BubbleColor"))
                HStack {
                    Image(icon)
                        .frame(width: 38, height: 38)
                        .opacity(icon.contains("Inactive") ? 0.5 : 1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
