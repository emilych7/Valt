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

    // Independent loads in parallel)
    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository

        Task {
            async let usernameTask: Void = fetchAuthenticatedUsername()
            async let countTask:    Void = fetchDraftCount()
            async let pubCountTask: Void = fetchPublishedCount()
            async let draftsTask:   Void = loadDrafts()
            async let avatarTask:   Void = fetchProfilePicture()
            _ = await (usernameTask, countTask, pubCountTask, draftsTask, avatarTask)
        }
    }

    // Loads

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
            self.userLoadingState = .error(error)
        }
    }

    // Uses Firestore aggregation count
    func fetchDraftCount() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let query = Firestore.firestore()
                .collection("drafts")
                .whereField("userID", isEqualTo: userID)

            let agg = try await query.count.getAggregation(source: .server)
            self.draftCount = Int(truncating: agg.count)
            // Don't force .complete here if cards still loading; just avoid 'empty' flicker
            if self.draftCount == 0 { self.userLoadingState = .empty }
        } catch {
            print("Count error: \(error.localizedDescription)")
            self.draftCount = 0
        }
    }

    func fetchPublishedCount() async {
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
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let asyncFetch: (String) async throws -> [Draft] = repository.fetchDrafts
            self.drafts = try await asyncFetch(userID)
            self.cardLoadingState = drafts.isEmpty ? .empty : .complete
        } catch {
            print("Error loading drafts: \(error.localizedDescription)")
            self.cardLoadingState = .error(error)
            self.drafts = []
        }
    }




    // MARK: - Mutations (unchanged behavior)

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

    // Fetch profile picture
    func fetchProfilePicture() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Try a small thumbnail first (best UX if you create these on upload)
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

        // Fallback: full-size, capped at 2 MB
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
            self.userLoadingState = .error(error)
        }
    }

    private func downloadImage(ref: StorageReference, maxBytes: Int64) async throws -> UIImage? {
        let url = try await ref.downloadURL()
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }

    // Async to avoid capturing a non-Sendable UIImage in a Task closure
    func uploadProfilePicture(_ image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let fullRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        do {
            self.userLoadingState = .loading
            _ = try await fullRef.putDataAsync(imageData, metadata: nil)
            self.profileImage = image
            // (Optional) also generate & upload a thumb to speed future loads
            print("Profile picture uploaded and UI updated.")
            self.userLoadingState = .complete
        } catch {
            print("Error uploading profile picture: \(error.localizedDescription)")
            self.userLoadingState = .error(error)
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
}
