import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var usernameSelectionState: InputStatus = .idle
    @Published var emailSelectionState: InputStatus = .idle
    
    @Published var isSaving = false
    @Published var errorMessage: String?
    @AppStorage("selectedAppearance") var selectedAppearance: String = "Auto"
    
    private var availabilityTask: Task<Void, Never>?

    var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil // 'nil' means use system settings
        }
    }

    func checkUsernameAvailability(for name: String, currentUsername: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Cancel previous pending check
        availabilityTask?.cancel()
        
        // Immediate local checks
        if cleanName.isEmpty {
            usernameSelectionState = .invalid
            return
        }
        if cleanName == currentUsername.lowercased() {
            usernameSelectionState = .idle
            return
        }
        
        if cleanName.count < 3 {
            usernameSelectionState = .invalid
            return
        }

        usernameSelectionState = .loading

        availabilityTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            guard !Task.isCancelled else { return }

            let db = Firestore.firestore()
            do {
                let doc = try await db.collection("usernames").document(cleanName).getDocument()
                
                if !Task.isCancelled {
                    usernameSelectionState = doc.exists ? .invalid : .valid
                }
            } catch {
                print("Availability check error: \(error)")
                usernameSelectionState = .error
            }
        }
    }
    
    func checkEmailAvailability(for email: String, currentEmail: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        availabilityTask?.cancel()
        
        if cleanEmail.isEmpty {
            emailSelectionState = .idle
            return
        }
        
        if cleanEmail == currentEmail.lowercased() {
            emailSelectionState = .idle
            return
        }
        
        // Local Regex Validation
        guard isValidEmail(cleanEmail) else {
            emailSelectionState = .invalid
            errorMessage = "Please enter a valid email address."
            return
        }

        // Remote Firestore check
        emailSelectionState = .loading
        errorMessage = nil

        availabilityTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }

            let db = Firestore.firestore()
            do {
                let doc = try await db.collection("emails").document(cleanEmail).getDocument()
                
                if !Task.isCancelled {
                    if doc.exists {
                        emailSelectionState = .invalid
                        errorMessage = "This email is already in use."
                    } else {
                        emailSelectionState = .valid
                    }
                }
            } catch {
                emailSelectionState = .error
                errorMessage = "Database error. Please try again."
            }
        }
    }
    
    // Update Email (sends verification first)
    func updateEmail(to newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }

    // Update Username
    func updateUsername(to newName: String, oldName: String) async throws {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let oldNameClean = oldName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let newNameClean = newName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard oldNameClean != newNameClean else { return }
        
        let check = try await db.collection("usernames").document(newNameClean).getDocument()
        if check.exists {
            usernameSelectionState = .invalid
            throw NSError(domain: "UsernameError", code: 409, userInfo: [NSLocalizedDescriptionKey: "Username already taken"])
        }

        let batch = db.batch()
        let oldUsernameRef = db.collection("usernames").document(oldNameClean)
        let newUsernameRef = db.collection("usernames").document(newNameClean)
        let userProfileRef = db.collection("users").document(uid)
        
        batch.deleteDocument(oldUsernameRef)
        batch.setData(["userID": uid], forDocument: newUsernameRef)
        batch.updateData(["username": newNameClean], forDocument: userProfileRef)
        
        try await batch.commit()
        usernameSelectionState = .valid
        print("Successfully swapped username from \(oldNameClean) to \(newNameClean)")
    }
    
    func getPlaceholder(for type: EditFieldType, currentUsername: String) -> String {
        switch type {
        case .username:
            return currentUsername
        case .email:
            return Auth.auth().currentUser?.email ?? "Email"
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let db = Firestore.firestore()
        
        // Fetch data needed for cleanup before deleting documents
        let userDoc = try await db.collection("users").document(uid).getDocument()
        let username = userDoc.data()?["username"] as? String
        
        do {
            // Clean up Firestore
            let batch = db.batch()
            batch.deleteDocument(db.collection("users").document(uid))
            
            if let username = username {
                batch.deleteDocument(db.collection("usernames").document(username.lowercased()))
            }
            
            try await batch.commit()
            
            // Clean up Storage
            let storageRef = Storage.storage().reference().child("profilePictures/\(uid).jpg")
            do {
                try await storageRef.delete()
            } catch {
                print("Storage cleanup skipped: \(error.localizedDescription)")
            }

            // Delete the Auth Account
            try await user.delete()
            
        } catch {
            let nsError = error as NSError
            
            // Check if the user was already successfully deleted during this process
            if nsError.code == AuthErrorCode.userNotFound.rawValue {
                print("User already deleted.")
                return // Exit successfully
            }
            
            if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                self.errorMessage = "For security, please sign out and sign back in to delete your account."
            } else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
