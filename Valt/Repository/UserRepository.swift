import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol UserRepositoryProtocol {
    func fetchUserProfile(uid: String) async throws -> (username: String?, pin: String?)
    func fetchProfilePicture(uid: String) async throws -> (image: UIImage?, downloadURL: URL?)
    func uploadProfilePicture(uid: String, image: UIImage) async throws
    func deleteProfilePicture(uid: String) async throws
    func savePin(uid: String, pin: String) async throws
    func reloadUser() async throws
    
    var currentUID: String? { get }
    var currentUserEmail: String? { get }
    
    func doesProfileExist(uid: String) async throws -> Bool
    func isUsernameAvailable(_ username: String) async throws -> Bool
    func isEmailAvailable(_ email: String) async throws -> Bool
    func createProfile(uid: String, username: String, email: String) async throws
    func updateUsername(uid: String, oldName: String, newName: String) async throws
    func updateEmail(to newEmail: String) async throws
    func updateAppearancePreference(uid: String, appearance: String) async throws
    func deleteAccount(password: String?) async throws
    func fetchEmailForUsername(_ username: String) async throws -> String?
}

final class UserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }

    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }

    func fetchUserProfile(uid: String) async throws -> (username: String?, pin: String?) {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard let data = snapshot.data() else {
            return (nil, nil)
        }
        let username = data["username"] as? String
        let pin = data["hiddenPin"] as? String
        return (username, pin)
    }

    func fetchProfilePicture(uid: String) async throws -> (image: UIImage?, downloadURL: URL?) {
        let thumbRef = storage.reference().child("profilePictures/\(uid)_thumb.jpg")
        do {
            if let img = try await downloadImage(ref: thumbRef, maxBytes: 512 * 1024) {
                return (img, nil)
            }
        } catch { }

        let fullRef = storage.reference().child("profilePictures/\(uid).jpg")
        do {
            if let img = try await downloadImage(ref: fullRef, maxBytes: 2 * 1024 * 1024) {
                let url = try? await fullRef.downloadURL()
                return (img, url)
            }
        } catch {
            let nsError = error as NSError
            if nsError.domain == StorageErrorDomain,
               let code = StorageErrorCode(rawValue: nsError.code),
               code == .objectNotFound {
                return (nil, nil)
            }
            throw error
        }

        return (nil, nil)
    }

    func uploadProfilePicture(uid: String, image: UIImage) async throws {
        let fullRef = storage.reference().child("profilePictures/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "UserRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        _ = try await fullRef.putDataAsync(imageData, metadata: nil)
    }

    func deleteProfilePicture(uid: String) async throws {
        let fullRef = storage.reference().child("profilePictures/\(uid).jpg")
        do {
            try await fullRef.delete()
        } catch {
            let nsError = error as NSError
            if nsError.domain == StorageErrorDomain,
               let code = StorageErrorCode(rawValue: nsError.code),
               code == .objectNotFound {
                return
            }
            throw error
        }
    }

    func savePin(uid: String, pin: String) async throws {
        let docRef = db.collection("users").document(uid)
        try await docRef.setData(["hiddenPin": pin], merge: true)
    }

    func reloadUser() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.reload()
    }

    func doesProfileExist(uid: String) async throws -> Bool {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        return snapshot.exists
    }

    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let cleanName = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let doc = try await db.collection("usernames").document(cleanName).getDocument()
        return !doc.exists
    }

    func isEmailAvailable(_ email: String) async throws -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let doc = try await db.collection("emails").document(cleanEmail).getDocument()
        return !doc.exists
    }

    func fetchEmailForUsername(_ username: String) async throws -> String? {
        let cleanName = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let usernameDoc = try await db.collection("usernames").document(cleanName).getDocument()
        guard let userID = usernameDoc.data()?["userID"] as? String else { return nil }
        
        let userDoc = try await db.collection("users").document(userID).getDocument()
        return userDoc.data()?["email"] as? String
    }

    func createProfile(uid: String, username: String, email: String) async throws {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let usernameRef = db.collection("usernames").document(cleanUsername)
        let snapshot = try await usernameRef.getDocument()
        if snapshot.exists {
            throw NSError(domain: "UserRepository", code: 409, userInfo: [NSLocalizedDescriptionKey: "This username is already taken."])
        }

        let batch = db.batch()
        let userRef = db.collection("users").document(uid)
        let emailRef = db.collection("emails").document(cleanEmail)
        
        batch.setData(["userID": uid], forDocument: emailRef)
        let userData: [String: Any] = [
            "userID": uid,
            "email": cleanEmail,
            "username": cleanUsername,
            "createdAt": FieldValue.serverTimestamp()
        ]
        batch.setData(userData, forDocument: userRef)
        batch.setData(["userID": uid], forDocument: usernameRef)
        try await batch.commit()
    }

    func updateUsername(uid: String, oldName: String, newName: String) async throws {
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
    }

    func updateEmail(to newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "UserRepository", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user."])
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }

    func updateAppearancePreference(uid: String, appearance: String) async throws {
        let userProfileRef = db.collection("users").document(uid)
        try await userProfileRef.updateData(["users": appearance])
    }

    func deleteAccount(password: String?) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        if let password = password, !password.isEmpty, let email = user.email {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            do {
                try await user.reauthenticate(with: credential)
            } catch {
                print("Reauthentication failed: \(error.localizedDescription)")
            }
        }
        
        let userDoc = try? await db.collection("users").document(uid).getDocument()
        let username = userDoc?.data()?["username"] as? String
        
        do {
            let batch = db.batch()
            batch.deleteDocument(db.collection("users").document(uid))
            if let username = username {
                batch.deleteDocument(db.collection("usernames").document(username.lowercased()))
            }
            try? await batch.commit()
            
            let storageRef = storage.reference().child("profilePictures/\(uid).jpg")
            do {
                try await storageRef.delete()
            } catch {
                print("Storage cleanup skipped: \(error.localizedDescription)")
            }

            try await user.delete()
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.userNotFound.rawValue {
                print("User already deleted.")
                return
            }
            throw error
        }
    }

    private func downloadImage(ref: StorageReference, maxBytes: Int64) async throws -> UIImage? {
        let url = try await ref.downloadURL()
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
}
