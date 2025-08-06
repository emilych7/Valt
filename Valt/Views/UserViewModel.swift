import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import UIKit

@MainActor
final class UserViewModel: ObservableObject {
    @Published var draftCount: Int = 0
    @Published var drafts: [Draft] = []
    @Published var profileImage: UIImage? = nil
    @Published var profilePictureURL: URL? = nil

    private let repository: DraftRepositoryProtocol
    
    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
        
        // Initial data loading
        fetchDraftCount()
        loadDrafts()
        fetchProfilePicture()
    }
    
    // Fetches the count of drafts from Firebase
    func fetchDraftCount() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Task {
            do {
                let snapshot = try await Firestore.firestore()
                    .collection("drafts")
                    .whereField("userID", isEqualTo: userID)
                    .getDocuments()
                self.draftCount = snapshot.documents.count
            } catch {
                print("Error fetching drafts count: \(error.localizedDescription)")
                self.draftCount = 0
            }
        }
    }
    
    // Loads all drafts for the current user from Firebase
    func loadDrafts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                self.drafts = try await repository.fetchDrafts(for: userID)
            } catch {
                print("Error loading drafts: \(error.localizedDescription)")
                self.drafts = []
            }
        }
    }
    
    // Deletes a draft from Firestore and updates the local list
    func deleteDraft(draftID: String) async {
        do {
            try await repository.deleteDraft(draftID: draftID)
            
            // Update local state after success
            if let index = self.drafts.firstIndex(where: { $0.id == draftID }) {
                self.drafts.remove(at: index)
                self.draftCount = self.drafts.count // Update count
            }
            print("Draft successfully deleted from Firestore and UI.")
        } catch {
            print("Error deleting draft: \(error.localizedDescription)")
        }
    }
    
    // Adds a new draft to Firestore and updates the local list
    func addDraft(_ draft: Draft) async {
        do {
            try await repository.saveDraft(draft: draft)
            // New draft appears at the top
            self.drafts.insert(draft, at: 0)
            self.draftCount = self.drafts.count // Update count
            print("Draft successfully added to Firestore and UI.")
        } catch {
            print("Error adding draft: \(error.localizedDescription)")
        }
    }
    
    // Fetches the user's profile picture from Firebase Storage
    func fetchProfilePicture() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        
        Task {
            do {
                let url = try await storageRef.downloadURL()
                self.profilePictureURL = url
                
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    self.profileImage = uiImage
                }
            } catch {
                print("Error fetching profile picture: \(error.localizedDescription)")
            }
        }
    }
    
    // Uploads a new profile picture to Firebase Storage
    func uploadProfilePicture(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        Task { 
            do {
                _ = try await storageRef.putDataAsync(imageData, metadata: nil)
                self.profileImage = image
                print("Profile picture uploaded and UI updated.")
            } catch {
                print("Error uploading profile picture: \(error.localizedDescription)")
            }
        }
    }
}
