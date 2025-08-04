import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

final class ProfileViewModel: ObservableObject {
    @Published var draftCount: Int = 0
    @Published var drafts: [Draft] = []
    
    @Published var profileImage: UIImage? = nil
    @Published var profilePictureURL: URL? = nil

    private let repository: DraftRepositoryProtocol
    
    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
        fetchDraftCount()
        loadDrafts()
        fetchProfilePicture() // Load profile picture and drafts on init
    }
    
    // Fetch drafts
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
            DispatchQueue.main.async {
                self.drafts = drafts
            }
        }
    }
    
    // Fetch profile picture
    func fetchProfilePicture() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        
        storageRef.downloadURL { [weak self] url, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching existing profile picture: \(error.localizedDescription)")
                return
            }
            self.profilePictureURL = url
            
            // Download the image data
            if let downloadURL = url {
                URLSession.shared.dataTask(with: downloadURL) { data, _, _ in
                    if let data = data, let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImage = uiImage
                        }
                    }
                }.resume()
            }
        }
    }
    
    // Upload a new profile picture
    func uploadProfilePicture(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                print("Error uploading profile picture: \(error.localizedDescription)")
                return
            }
            // Update Published property so UI updates immediately
            DispatchQueue.main.async {
                self.profileImage = image
            }
        }
    }
}
