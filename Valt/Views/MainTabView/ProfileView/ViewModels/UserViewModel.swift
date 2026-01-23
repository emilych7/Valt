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
    private var authHandler: AuthStateDidChangeListenerHandle?

    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
        
        authHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self, user != nil else { return }
            Task {
                await self.fetchAllData()
            }
        }
    }
    
    func fetchAllData() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user. No fetching data.")
            return
        }
        
        print("Starting authenticated fetch for: \(uid)")
        
        async let avatarTask:    Void = fetchProfilePicture()
        async let usernameTask:  Void = fetchAuthenticatedUsername()
        async let countTask:     Void = fetchDraftCount()
        async let pubCountTask:  Void = fetchPublishedCount()
        async let draftsTask:    Void = loadDrafts()
        
        _ = await (avatarTask, usernameTask, countTask, pubCountTask, draftsTask)
    }
    
    var currentUserEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }

    var currentUserPhone: String {
        Auth.auth().currentUser?.phoneNumber ?? ""
    }

    // Grabs current username
    func fetchAuthenticatedUsername() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        let q = Firestore.firestore()
            .collection("usernames")
            .whereField("userID", isEqualTo: uid)

        do {
            // Cache-first
            if let cached = try? await q.getDocuments(source: .cache).documents.first {
                self.username = cached.documentID
            }
            // Server refresh
            let fresh = try await q.getDocuments(source: .server)
            if let doc = fresh.documents.first {
                self.username = doc.documentID
            } else {
                print("No username found for user ID: \(uid)")
            }
        } catch {
            print("Error fetching username: \(error.localizedDescription)")
            self.userLoadingState = .error(error.localizedDescription)
        }
    }
    
    // Uses Firestore aggregation count
    func fetchDraftCount() async {
        print("Fetching draft count...")
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let query = Firestore.firestore()
                .collection("drafts")
                .whereField("userID", isEqualTo: userID)

            let agg = try await query.count.getAggregation(source: .server)
            self.draftCount = Int(truncating: agg.count)
            if self.draftCount == 0 { self.userLoadingState = .empty }
        } catch {
            print("Count error: \(error.localizedDescription)")
            self.draftCount = 0
        }
    }

    func fetchPublishedCount() async {
        print("Fetching published draft count...")
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let query = Firestore.firestore()
                .collection("drafts")
                .whereField("userID", isEqualTo: userID)
                .whereField("isPublished", isEqualTo: true)

            let agg = try await query.count.getAggregation(source: .server)
            self.publishedDraftCount = Int(truncating: agg.count)
        } catch {
            print("Count error: \(error.localizedDescription)")
            self.publishedDraftCount = 0
        }
    }

    // Loads drafts
    func loadDrafts() async {
        print("Loading drafts...")
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let asyncFetch: (String) async throws -> [Draft] = repository.fetchDrafts
            self.drafts = try await asyncFetch(userID)
            self.cardLoadingState = drafts.isEmpty ? .empty : .complete
        } catch {
            print("Error loading drafts: \(error.localizedDescription)")
            self.cardLoadingState = .error(error.localizedDescription)
            self.drafts = []
        }
    }

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
            print("Draft successfully deleted from Firestore and UI")
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

    // Fetch profile picture
    func fetchProfilePicture() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let thumbRef = Storage.storage().reference().child("profilePictures/\(uid)_thumb.jpg")
        do {
            self.userLoadingState = .loading
            if let img = try await downloadImage(ref: thumbRef, maxBytes: 512 * 1024) {
                self.profileImage = img
                self.userLoadingState = .complete
                return
            }
        } catch {
            // fall through to full-size attempt
        }

        let fullRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        do {
            if let img = try await downloadImage(ref: fullRef, maxBytes: 2 * 1024 * 1024) {
                self.profileImage = img
                // Keep URL
                if let url = try? await fullRef.downloadURL() {
                    self.profilePictureURL = url
                }
                self.userLoadingState = .complete
            } else {
                self.userLoadingState = .empty
            }
        } catch {
            print("Error fetching profile picture: \(error.localizedDescription)")
            self.userLoadingState = .error(error.localizedDescription)
        }
    }

    private func downloadImage(ref: StorageReference, maxBytes: Int64) async throws -> UIImage? {
        let url = try await ref.downloadURL()
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }

    func uploadProfilePicture(_ image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let fullRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        do {
            self.userLoadingState = .loading
            _ = try await fullRef.putDataAsync(imageData, metadata: nil)
            self.profileImage = image
            print("Profile picture uploaded and UI updated.")
            self.userLoadingState = .complete
        } catch {
            print("Error uploading profile picture: \(error.localizedDescription)")
            self.userLoadingState = .error(error.localizedDescription)
        }
    }
    

    // Search
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
    
    func reloadUser() async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.reload()
            // Manually trigger a UI refresh
            objectWillChange.send()
            
            // Refresh the Firestore username just in case it changed
            await fetchAuthenticatedUsername()
        } catch {
            print("Error reloading: \(error.localizedDescription)")
        }
    }
}
