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
    private let db = Firestore.firestore()

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = (user != nil)
                if let user { self?.errorMessage = nil; print("User is logged in: \(user.uid)") }
                else { print("User is logged out.") }
            }
        }
    }
    
    // Validate a password string
    func isValidPassword(_ password: String) -> Bool {
        // Trim spaces first
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        
        // At least one uppercase, lowercase, digit, symbol, min 8 characters
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", passwordRegx)
        return passwordCheck.evaluate(with: trimmedPassword)
    }

    // Return a list of missing password requirements
    func getMissingValidation(_ password: String) -> [String] {
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        var errors: [String] = []
        
        if !NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*").evaluate(with: trimmedPassword) {
            errors.append("least one uppercase")
        }
        if !NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: trimmedPassword) {
            errors.append("least one digit")
        }
        if !NSPredicate(format: "SELF MATCHES %@", ".*[!&^%$#@()/]+.*").evaluate(with: trimmedPassword) {
            errors.append("least one symbol")
        }
        if !NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: trimmedPassword) {
            errors.append("least one lowercase")
        }
        if trimmedPassword.count < 8 {
            errors.append("min 8 characters total")
        }
        return errors
    }
    

    // Normalize usernames to lowercame
    func normalizedUsername(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    // Email heuristic
    func looksLikeEmail(_ text: String) -> Bool {
        text.contains("@")
    }

    // Sign Up (Email/Username + Password)
    func signUp(email: String, password: String, username: String) async {
        errorMessage = nil
        do {
            let uname = normalizedUsername(username)

            // Reserve the username (usernames/{username} -> { userID })
            let usernameRef = db.collection("usernames").document(uname)
            let snapshot = try await usernameRef.getDocument()

            guard !snapshot.exists else {
                self.errorMessage = "This username is already taken. Please choose another one."
                print("Error: Username '\(uname)' is already taken.")
                return
            }

            // Create auth user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("Successfully signed up user: \(result.user.uid)")

            // Atomically write user profile + username mapping
            let batch = db.batch()

            let userRef = db.collection("users").document(result.user.uid)
            let userData: [String: Any] = [
                "userID": result.user.uid,
                "email": result.user.email ?? "",
                "username": uname,
                "createdAt": FieldValue.serverTimestamp()
            ]
            batch.setData(userData, forDocument: userRef)

            let userNameMappingRef = db.collection("usernames").document(uname)
            batch.setData(["userID": result.user.uid], forDocument: userNameMappingRef)

            try await batch.commit()
            print("User data saved to Firestore.")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error signing up: \(error.localizedDescription)")
        }
    }

    // Sign In (Username OR Email)
    func signIn(usernameOrEmail: String, password: String) async {
        errorMessage = nil
        do {
            if looksLikeEmail(usernameOrEmail) {
                let result = try await Auth.auth().signIn(withEmail: usernameOrEmail, password: password)
                print("Successfully signed in user: \(result.user.uid)")
                return
            }

            // Username flow: lookup userID -> fetch user's email -> sign in with email
            let uname = normalizedUsername(usernameOrEmail)

            // 1) usernames/{username} -> userID
            let usernameDoc = try await db.collection("usernames").document(uname).getDocument()
            guard let data = usernameDoc.data(),
                  let userID = data["userID"] as? String else {
                self.errorMessage = "Username not found."
                print("Error: Username '\(uname)' not found.")
                return
            }

            // 2) users/{userID} -> email
            let userDoc = try await db.collection("users").document(userID).getDocument()
            guard let userData = userDoc.data(),
                  let email = userData["email"] as? String, !email.isEmpty else {
                self.errorMessage = "Could not resolve email for that username."
                print("Error: Email not found for userID \(userID).")
                return
            }

            // 3) Firebase Auth sign-in (email + password)
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("Successfully signed in via username. userID: \(result.user.uid)")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error signing in: \(error.localizedDescription)")
        }
    }

    // Direct email-only entry point
    func signIn(email: String, password: String) async {
        await signIn(usernameOrEmail: email, password: password)
    }

    // Sign Out
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

    // Reset Password Via Email
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
