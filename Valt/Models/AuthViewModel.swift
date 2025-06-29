import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    private var authHandle: AuthStateDidChangeListenerHandle?
    private var db = Firestore.firestore()

    init() {
        // Observe changes in authentication state
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = (user != nil)
                if user != nil {
                    self?.errorMessage = nil // Clear any previous errors on successful login
                    print("User is logged in: \(user?.uid ?? "Unknown")")
                } else {
                    print("User is logged out.")
                }
            }
        }
    }

    // MARK: Email and Password Authentication

    func signUp(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("Successfully signed up user: \(result.user.uid)")

            let userData: [String: Any] = [
                "uid": result.user.uid,
                "email": result.user.email ?? "",
                "createdAt": FieldValue.serverTimestamp()
            ]
            try await db.collection("users").document(result.user.uid).setData(userData)
            print("User data saved to Firestore.")

        } catch {
            self.errorMessage = error.localizedDescription
            print("Error signing up: \(error.localizedDescription)")
            
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("Successfully signed in user: \(result.user.uid)")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error signing in: \(error.localizedDescription)")
            
        }
    }

    func signOut() async {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
            print("User signed out.")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error signing out: \(error.localizedDescription)")
            
        }
    }

    func resetPassword(email: String) async {
        errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            self.errorMessage = "Password reset email sent to \(email)."
            
            print("Password reset email sent to \(email).")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error sending password reset: \(error.localizedDescription)")
            
        }
    }

    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
