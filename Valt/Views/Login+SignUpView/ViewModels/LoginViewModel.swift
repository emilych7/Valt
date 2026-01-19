import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class LoginViewModel: ObservableObject {
    @Published var identifier = "" // Email or Username
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()

    func performSignIn() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            var emailToSignIn = identifier
            
            // If it's not an email
            if !identifier.contains("@") {
                emailToSignIn = try await lookupEmailByUsername(identifier.lowercased())
            }
            
            try await Auth.auth().signIn(withEmail: emailToSignIn, password: password)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func lookupEmailByUsername(_ username: String) async throws -> String {
        let usernameDoc = try await db.collection("usernames").document(username).getDocument()
        guard let userID = usernameDoc.data()?["userID"] as? String else { throw AuthError.userNotFound }
        
        let userDoc = try await db.collection("users").document(userID).getDocument()
        guard let email = userDoc.data()?["email"] as? String else { throw AuthError.invalidData }
        return email
    }
    
    func signInWithGoogle(presenting viewController: UIViewController) async {
            guard GIDSignIn.sharedInstance.configuration != nil else {
                errorMessage = "Google Sign-In not configured."
                return
            }

            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
                let user = result.user
                guard let idToken = user.idToken?.tokenString else {
                    errorMessage = "Missing ID token."
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                _ = try await Auth.auth().signIn(with: credential)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
}

enum AuthError: Error { case userNotFound, invalidData }
