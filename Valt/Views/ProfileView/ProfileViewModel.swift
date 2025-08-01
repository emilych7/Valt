import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

final class ProfileViewModel: ObservableObject {
    @Published var draftCount: Int = 0
    @Published var drafts: [Draft] = []
    
    private let repository: DraftRepositoryProtocol
        
        init(repository: DraftRepositoryProtocol = DraftRepository()) {
            self.repository = repository
        }
    
    func fetchDraftCount() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("drafts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching drafts: \(error)")
                    self.draftCount = 0
                    return
                }
                self.draftCount = snapshot?.documents.count ?? 0
            }
    }
    
    func loadDrafts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        repository.fetchDrafts(for: userID) { drafts in
            self.drafts = drafts
        }
    }
    
}


