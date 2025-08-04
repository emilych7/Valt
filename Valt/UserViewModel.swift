import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class UserViewModel: ObservableObject {
    @Published var profilePicture: UIImage? = nil
    @Published var name: String? = nil
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()

    func loadUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        // 1️⃣ Fetch user document
        db.collection("users").document(userID).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No data for user document")
                return
            }

            // 2️⃣ Get name
            self?.name = data["name"] as? String ?? "User"

            // 3️⃣ Get profile picture URL
            if let profilePicURL = data["profilePictureURL"] as? String {
                self?.fetchProfileImage(from: profilePicURL)
            }
        }
    }
    
    private func fetchProfileImage(from urlString: String) {
        let storageRef = storage.reference(forURL: urlString)
        
        storageRef.getData(maxSize: 2 * 1024 * 1024) { [weak self] data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profilePicture = image
                }
            }
        }
    }
}
