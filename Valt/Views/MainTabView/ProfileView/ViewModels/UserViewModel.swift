import Foundation
import FirebaseAuth
import UIKit

@MainActor
final class UserViewModel: ObservableObject {
    @Published var cardLoadingState: ContentLoadingState = .loading
    @Published var userLoadingState: ContentLoadingState = .complete
    @Published var profileLoadingState: ContentLoadingState = .loading
    
    @Published var username: String = "@username"
    @Published var followerCount: Int = 0
    
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
    private let userRepository: UserRepositoryProtocol
    private var authHandler: AuthStateDidChangeListenerHandle?
    private var signOutObserver: NSObjectProtocol?
    private var isFetching = false
    
    private var storedPin: String? = nil
    
    var draftCount: Int {
        drafts.filter { !$0.isArchived }.count
    }

    var publishedDraftCount: Int {
        drafts.filter { $0.isPublished }.count
    }

    init(
        repository: DraftRepositoryProtocol = DraftRepository(),
        userRepository: UserRepositoryProtocol = UserRepository()
    ) {
        self.repository = repository
        self.userRepository = userRepository
        
        signOutObserver = NotificationCenter.default.addObserver(
            forName: .userDidSignOut,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.clearData()
            }
        }
        
        authHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                guard let user = user else {
                    self.clearData()
                    return
                }
                
                let isFederated = user.providerData.contains { 
                    $0.providerID == "google.com" || $0.providerID == "apple.com" 
                }
                guard isFederated || user.isEmailVerified else {
                    self.clearData()
                    return
                }
                
                if !self.isFetching {
                    await self.fetchAllData()
                }
            }
        }
    }
    
    deinit {
        if let handler = authHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
        if let observer = signOutObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func fetchAllData() async {
        guard !isFetching else { return }
        isFetching = true
        print("Fetching data...")
        userLoadingState = .loading
        
        guard Auth.auth().currentUser?.uid != nil else {
            isFetching = false
            clearData()
            return
        }

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchAuthenticatedUsername()
            }
            
            group.addTask {
                await self.fetchProfilePicture()
            }
            
            group.addTask {
                await self.loadDrafts()
            }
        }
        userLoadingState = .complete
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
        
        do {
            let (uname, pin) = try await userRepository.fetchUserProfile(uid: uid)
            if let uname = uname {
                self.username = uname
            }
            if let pin = pin {
                self.storedPin = pin
                self.hasPinSet = true
            }
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
            if error.isUnauthenticatedError {
                NotificationCenter.default.post(name: .userSessionInvalidated, object: nil)
            }
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
            if error.isUnauthenticatedError {
                NotificationCenter.default.post(name: .userSessionInvalidated, object: nil)
            }
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

        do {
            let (img, url) = try await userRepository.fetchProfilePicture(uid: uid)
            if let img = img {
                self.profileImage = img
                self.profilePictureURL = url
                self.profileLoadingState = .complete
            } else {
                self.profileLoadingState = .empty
            }
        } catch {
            print("Error fetching profile picture: \(error.localizedDescription)")
            self.profileLoadingState = .error(error.localizedDescription)
        }
    }

    func uploadProfilePicture(_ image: UIImage) async {
        self.profileLoadingState = .loading
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            try await userRepository.uploadProfilePicture(uid: uid, image: image)
            self.profileImage = image
            print("Profile picture uploaded and UI updated.")
            self.profileLoadingState = .complete
        } catch {
            print("Error uploading profile picture: \(error.localizedDescription)")
            self.profileLoadingState = .error(error.localizedDescription)
        }
    }
    
    func reloadUser() async {
        do {
            try await userRepository.reloadUser()
            objectWillChange.send()
            await fetchAuthenticatedUsername()
        } catch {
            print("Error reloading: \(error.localizedDescription)")
        }
    }
    
    func createPin(newPin: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user found.")
            return
        }
                
        Task {
            do {
                try await userRepository.savePin(uid: uid, pin: newPin)
                print("PIN successfully saved to Firestore. Setting hasPinSet = true")
                hasPinSet = true
                storedPin = newPin
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
                print("Correct PIN")
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
            }
        }
    }
    
    func clearData() {
        self.drafts = []
        self.username = "@username"
        self.followerCount = 0
        self.profileImage = nil
        self.profilePictureURL = nil
        self.hasPinSet = false
        self.storedPin = nil
        self.isUnlocked = false
        self.enteredPin = ""
        self.newPin = ""
        self.confirmNewPin = ""
        self.pinColor = "TextColor"
        self.shakeAttempts = 0
        self.isFetching = false
        self.cardLoadingState = .complete
        self.userLoadingState = .complete
        self.profileLoadingState = .empty
    }
}
