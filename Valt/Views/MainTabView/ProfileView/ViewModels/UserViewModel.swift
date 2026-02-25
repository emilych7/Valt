import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import UIKit

@MainActor
final class UserViewModel: ObservableObject {
    @Published var cardLoadingState: ContentLoadingState = .loading
    @Published var userLoadingState: ContentLoadingState = .complete
    @Published var profileLoadingState: ContentLoadingState = .loading
    @Published var username: String = "@username"
    @Published var drafts: [Draft] = []
    @Published var profileImage: UIImage? = nil
    @Published var profilePictureURL: URL? = nil
    
    @Published var hasPinSet: Bool = false
    @Published var newPin: String = ""
    @Published var confirmNewPin: String = ""
    
    @Published var enteredPin: String = ""
    @Published var pinColor: String = "TextColor"
    @Published var isUnlocked: Bool = false
    @Published var maxDigits: Int = 4
    @Published var shakeAttempts: CGFloat = 0
    
    private let repository: DraftRepositoryProtocol
    private var authHandler: AuthStateDidChangeListenerHandle?
    private var isFetching = false
    
    private var storedPin: String? = nil
    
    var draftCount: Int {
        drafts.filter { !$0.isArchived }.count
    }

    var publishedDraftCount: Int {
        drafts.filter { $0.isPublished }.count
    }

    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
        
        authHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self, user != nil else { return }
            if !self.isFetching {
                Task {
                    await self.fetchAllData()
                }
            }
        }
    }
    
    func fetchAllData() async {
        guard !isFetching else { return }
        isFetching = true
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user. No fetching data.")
            isFetching = false
            return
        }
        
        self.profileLoadingState = .loading
        self.cardLoadingState = .loading
        
        print("Starting authenticated fetch for: \(uid)")
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchProfilePicture() }
            group.addTask { await self.fetchAuthenticatedUsername() }
            group.addTask { await self.loadDrafts() }
        }
        
        isFetching = false
    }
    
    var currentUserEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }

    var currentUserPhone: String {
        Auth.auth().currentUser?.phoneNumber ?? ""
    }

    func fetchAuthenticatedUsername() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        do {
            let snapshot = try await userRef.getDocument()
            if let data = snapshot.data() {
                if let uname = data["username"] as? String {
                    self.username = uname
                }
                
                // Grab the PIN too
                if let pin = data["hiddenPin"] as? String {
                    self.storedPin = pin
                    self.hasPinSet = true
                }
            }
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
        }
    }
 
    func loadDrafts() async {
        print("Loading drafts...")
        self.cardLoadingState = .loading
        guard let userID = Auth.auth().currentUser?.uid else { return }
        do {
            let asyncFetch: (String) async throws -> [Draft] = repository.fetchDrafts
            self.drafts = try await asyncFetch(userID)
            self.cardLoadingState = drafts.isEmpty ? .empty : .complete
        } catch {
            print("Error loading drafts: \(error.localizedDescription)")
            self.cardLoadingState = .error(error.localizedDescription)
            self.drafts = []
            // self.cardLoadingState = .complete
        }
    }

    func updateDraft(draftID: String, updatedFields: [String: Any]) async {
        do {
            try await repository.updateDraft(draftID: draftID, with: updatedFields)
            
            if let index = drafts.firstIndex(where: { $0.id == draftID }) {
                for (key, value) in updatedFields {
                    drafts[index].updateField(key: key, value: value)
                }
                objectWillChange.send()
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
                // No need to manually update draftCount anymore!
            }
        } catch {
            print("Error deleting draft: \(error.localizedDescription)")
            self.cardLoadingState = .error(error.localizedDescription)
        }
    }

    func addDraft(_ draft: Draft) async {
        do {
            try await repository.saveDraft(draft: draft)
            self.drafts.insert(draft, at: 0)
            self.cardLoadingState = .complete
            print("Draft successfully added to Firestore and UI.")
        } catch {
            print("Error adding draft: \(error.localizedDescription)")
        }
    }

    func fetchProfilePicture() async {
        self.profileLoadingState = .loading
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let thumbRef = Storage.storage().reference().child("profilePictures/\(uid)_thumb.jpg")
        do {
            if let img = try await downloadImage(ref: thumbRef, maxBytes: 512 * 1024) {
                self.profileImage = img
                self.profileLoadingState = .complete
                return
            }
        } catch { }

        let fullRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        do {
            if let img = try await downloadImage(ref: fullRef, maxBytes: 2 * 1024 * 1024) {
                self.profileImage = img
                if let url = try? await fullRef.downloadURL() {
                    self.profilePictureURL = url
                }
                self.profileLoadingState = .complete
            } else {
                self.profileLoadingState = .empty
            }
        } catch {
            print("Error fetching profile picture: \(error.localizedDescription)")
            self.profileLoadingState = .error(error.localizedDescription)
        }
    }

    private func downloadImage(ref: StorageReference, maxBytes: Int64) async throws -> UIImage? {
        let url = try await ref.downloadURL()
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }

    func uploadProfilePicture(_ image: UIImage) async {
        self.profileLoadingState = .loading
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let fullRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        do {
            _ = try await fullRef.putDataAsync(imageData, metadata: nil)
            self.profileImage = image
            print("Profile picture uploaded and UI updated.")
            self.profileLoadingState = .complete
        } catch {
            print("Error uploading profile picture: \(error.localizedDescription)")
            self.profileLoadingState = .error(error.localizedDescription)
        }
    }
    
    func reloadUser() async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.reload()
            objectWillChange.send()
            await fetchAuthenticatedUsername()
        } catch {
            print("Error reloading: \(error.localizedDescription)")
        }
    }
    
    func createPin(newPin: String) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user found.")
            return
        }
                
        let docRef = db.collection("users").document("\(uid)")

        Task {
            do {
                try await docRef.setData(["hiddenPin": newPin], merge: true)
                print("PIN successfully saved to Firestore. Setting hasPinSet = true")
                hasPinSet = true
            } catch {
                print("Error saving PIN: \(error.localizedDescription)")
            }
        }
    }
    
    func checkPin(enteredPin: String) -> Void {
        guard let correctPin = storedPin else {
            print("No PIN set for this user.")
            return
        }
        
        let feedbackGenerator = UINotificationFeedbackGenerator()
        
        guard enteredPin.count == maxDigits else { return }
        
        // Tiny delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if enteredPin == correctPin {
                self.pinColor = "TextColor"
                return self.isUnlocked = true
            } else {
                print("Incorrect PIN")
                self.shakeAttempts += 1
                self.pinColor = "ValtRed"
                
                feedbackGenerator.notificationOccurred(.error)
                
                // Clear the pin field after the shake
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.pinColor = "TextColor"
                    self.enteredPin = ""
                }
                
                return
            }
        }
    }
}
