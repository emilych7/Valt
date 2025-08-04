import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

final class HomeViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var isFavorited = false
    @Published var draftText = ""
    @Published var selectedMoreOption: MoreOption? = nil
    @Published var showMoreOptions: Bool = false
    @Published var bannerManager: BannerManager = BannerManager()

    
    func saveDraftToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        
        let db = Firestore.firestore()
        let draftData: [String: Any] = [
            "userID": userID,    
            "title": "Title",
            "content": draftText,
            "timestamp": FieldValue.serverTimestamp(),
            "isFavorited": isFavorited
        ]
        
        db.collection("drafts").addDocument(data: draftData) { error in
            if let error = error {
                print("Error saving draft to Firestore: \(error.localizedDescription)")
                self.bannerManager.show("Failed to save: \(error.localizedDescription)")
            } else {
                print("Successfully saved in Firestore.")
                self.draftText = ""
                self.isEditing = false
                self.bannerManager.show("Saved")
            }
        }
    }
}
