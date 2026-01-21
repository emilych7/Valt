import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class LoginViewModel: ObservableObject {
    enum Field { case identifier, password }
    
    @Published var identifier = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isGoogleLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()

    func performSignIn() async {
        print("Starting sign in")
        let uname = identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !uname.isEmpty else {
            self.errorMessage = "Username or email is required."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            var emailToSignIn = identifier
            
            if !identifier.contains("@") {
                emailToSignIn = try await lookupEmailByUsername(identifier.lowercased())
            }
            
            let result = try await Auth.auth().signIn(withEmail: emailToSignIn, password: password)
            
            // Check verification status
            if !result.user.isEmailVerified {
                print("Login success, but email not verified.")
            } else {
                print("Signed in and verified!")
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error signing in: \(error.localizedDescription)")
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
        print("Starting Google Sign In")
        isGoogleLoading = true
        defer { isGoogleLoading = false }

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
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
            
            if !userDoc.exists {
                // This person signed in but has no username, route them to the Signup flow
                print("Login success, but profile missing. Routing to setup...")
            }
            
        } catch {
            // Ignore user cancellation errors to keep the UI clean
            if (error as NSError).code != GIDSignInError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
            print("Error: \(error.localizedDescription)")
        }
    }
}

enum AuthError: Error { case userNotFound, invalidData }
