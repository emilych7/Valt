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
        let batch = db.batch()
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        let oldRef = db.collection("usernames").document(oldName)
        let newRef = db.collection("usernames").document(newName)
        
        batch.deleteDocument(oldRef)
        batch.setData(["userID": uid], forDocument: newRef)
        
        try await batch.commit()
    }

    // 3. Update Phone
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
}
