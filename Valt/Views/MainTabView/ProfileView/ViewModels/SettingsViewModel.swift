import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isSaving = false
    @Published var errorMessage: String?
    @AppStorage("selectedAppearance") var selectedAppearance: String = "Auto"
    
    var colorScheme: ColorScheme? {
                switch selectedAppearance {
                case "Light": return .light
                case "Dark": return .dark
                default: return nil // 'nil' means use system settings
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
        
        print("Successfully swapped username from \(oldNameClean) to \(newNameClean)")
    }

    // Update Phone
    func updatePhone(to newPhone: String) async throws {
        // Placeholder
    }
    
    func getPlaceholder(for type: EditFieldType, currentUsername: String) -> String {
        switch type {
        case .username:
            return currentUsername
        case .email:
            return Auth.auth().currentUser?.email ?? "Email"
        case .phone:
            return Auth.auth().currentUser?.phoneNumber ?? "Phone"
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
}
