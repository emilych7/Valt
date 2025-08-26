import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import UIKit

@MainActor
final class UserViewModel: ObservableObject {
    @Published var cardLoadingState: ContentLoadingState = .loading
    @Published var userLoadingState: ContentLoadingState = .loading
    
    @Published var username: String = "@username"
    @Published var draftCount: Int = 0
    @Published var publishedDraftCount: Int = 0
    @Published var drafts: [Draft] = []
    @Published var profileImage: UIImage? = nil
    @Published var profilePictureURL: URL? = nil
    @Published var usernameResults: [String] = []
    @Published var usernamePublishedDrafts: [Draft] = []

    private let repository: DraftRepositoryProtocol
    
    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository

        // Run initial loads without nesting Tasks inside each method.
        Task {
            await fetchAuthenticatedUsername()
            await fetchDraftCount()
            await fetchPublishedCount()
            await loadDrafts()
            await fetchProfilePicture()
        }
    }
    
    // MARK: - Loads

    // Grabs current user's username
    func fetchAuthenticatedUsername() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("usernames")
                .whereField("userID", isEqualTo: uid)
                .getDocuments()

            if let document = snapshot.documents.first {
                let name = document.documentID
                self.username = name
                // (optional) consider a loading state here if username gates other UI
                print("Authenticated user's username: \(name)")
            } else {
                print("No username found for user ID: \(uid)")
            }
        } catch {
            print("Error fetching username: \(error.localizedDescription)")
            self.userLoadingState = .error(error)
        }
    }

    // Fetches the count of drafts from Firebase
    func fetchDraftCount() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("drafts")
                .whereField("userID", isEqualTo: userID)
                .getDocuments()
            self.draftCount = snapshot.documents.count
            self.userLoadingState = (self.draftCount == 0) ? .empty : .complete
        } catch {
            print("Error fetching drafts count: \(error.localizedDescription)")
            self.draftCount = 0
        }
    }
    
    func fetchPublishedCount() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("drafts")
                .whereField("userID", isEqualTo: userID)
                .whereField("isPublished", isEqualTo: true)
                .getDocuments()
            self.publishedDraftCount = snapshot.documents.count
            print("Published drafts count: \(self.publishedDraftCount)")
        } catch {
            print("Error fetching published drafts count: \(error.localizedDescription)")
            self.publishedDraftCount = 0
        }
    }
    
    // Loads all drafts for the current user from Firebase
    func loadDrafts() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            self.drafts = try await repository.fetchDrafts(for: userID)
            self.cardLoadingState = drafts.isEmpty ? .empty : .complete
        } catch {
            print("Error loading drafts: \(error.localizedDescription)")
            self.cardLoadingState = .error(error)
            self.drafts = []
        }
    }
    
    // MARK: - Mutations

    func updateDraft(draftID: String, updatedFields: [String: Any]) async {
        do {
            try await repository.updateDraft(draftID: draftID, with: updatedFields)
            if let index = drafts.firstIndex(where: { $0.id == draftID }) {
                for (key, value) in updatedFields {
                    drafts[index].updateField(key: key, value: value)
                }
            }
        } catch {
            print("Error updating draft: \(error.localizedDescription)")
        }
    }
    
    func deleteDraft(draftID: String) async {
        do {
            try await repository.deleteDraft(draftID: draftID)
            if let index = self.drafts.firstIndex(where: { $0.id == draftID }) {
                self.drafts.remove(at: index)
                self.draftCount = self.drafts.count
                self.cardLoadingState = (draftCount == 0) ? .empty : .complete
            }
            print("Draft successfully deleted from Firestore and UI.")
        } catch {
            print("Error deleting draft: \(error.localizedDescription)")
        }
    }
    
    func addDraft(_ draft: Draft) async {
        do {
            try await repository.saveDraft(draft: draft)
            self.drafts.insert(draft, at: 0)
            self.draftCount = self.drafts.count
            self.cardLoadingState = .complete
            print("Draft successfully added to Firestore and UI.")
        } catch {
            print("Error adding draft: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Profile Picture

    func fetchProfilePicture() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        do {
            self.userLoadingState = .loading
            let url = try await storageRef.downloadURL()
            self.profilePictureURL = url
            
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                self.profileImage = uiImage
                self.userLoadingState = .complete
            } else {
                self.userLoadingState = .empty
            }
        } catch {
            print("Error fetching profile picture: \(error.localizedDescription)")
            self.userLoadingState = .error(error)
        }
    }
    
    /// Make this async to avoid capturing a non-Sendable `UIImage` in a `Task` closure.
    func uploadProfilePicture(_ image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        do {
            self.userLoadingState = .loading
            _ = try await storageRef.putDataAsync(imageData, metadata: nil)
            self.profileImage = image
            print("Profile picture uploaded and UI updated.")
            self.userLoadingState = .complete
        } catch {
            print("Error uploading profile picture: \(error.localizedDescription)")
            self.userLoadingState = .error(error)
        }
    }
    
    // MARK: - Search

    func searchUsernames(prefix: String) async {
        let trimmed = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.usernameResults = []
            return
        }
        do {
            let names = try await repository.searchUsernames(prefix: trimmed, limit: 15)
            self.usernameResults = names
        } catch {
            print("Error searching usernames: \(error.localizedDescription)")
            self.usernameResults = []
        }
    }

    func loadPublishedDrafts(for username: String) async {
        do {
            let items = try await repository.fetchPublishedDrafts(forUsername: username)
            self.usernamePublishedDrafts = items
        } catch {
            print("Error loading published drafts for \(username): \(error.localizedDescription)")
            self.usernamePublishedDrafts = []
        }
    }
}
