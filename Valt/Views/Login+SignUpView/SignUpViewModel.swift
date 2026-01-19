import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    
    func isFormValid() -> Bool {
        if username.isEmpty || email.isEmpty {
            errorMessage = "Please fill in all fields."
            return false
        }
        
        if password != passwordConfirmation {
            errorMessage = "Passwords do not match."
            return false
        }
        
        if !AuthValidator.isValidPassword(password) {
            let missing = AuthValidator.getMissingValidation(password)
            errorMessage = "Password missing: \(missing.joined(separator: ", "))"
            return false
        }
        
        return true
    }

    // Perform Sign Up
    func signUp() async {
        
            
            guard password == passwordConfirmation else {
                self.errorMessage = "Passwords do not match."
                return
            }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let uname = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                
                // Check Username availability
                let usernameRef = db.collection("usernames").document(uname)
                let snapshot = try await usernameRef.getDocument()
                
                if snapshot.exists {
                    self.errorMessage = "This username is already taken."
                    isLoading = false
                    return
                }
                
                // Create User in Firebase
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                
                // Batch Save to Firestore
                let batch = db.batch()
                let userRef = db.collection("users").document(result.user.uid)
                let userData: [String: Any] = [
                    "userID": result.user.uid,
                    "email": email,
                    "username": uname,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                batch.setData(userData, forDocument: userRef)
                batch.setData(["userID": result.user.uid], forDocument: usernameRef)
                
                try await batch.commit()
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
}
