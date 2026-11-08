import Foundation
import FirebaseAuth
import Combine
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

@MainActor
class LoginViewModel: NSObject, ObservableObject {
    enum Field { case identifier, password }
    
    @Published var identifier = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isGoogleLoading = false
    @Published var errorMessage: String?
    @Published var usernameBorderColor = "TextColor"
    @Published var passwordBorderColor = "TextColor"
    @Published var currentNonce: String?
    
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
        super.init()
    }

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
                guard let email = try await userRepository.fetchEmailForUsername(identifier.lowercased()) else {
                    throw AuthError.userNotFound
                }
                emailToSignIn = email
            }
            
            let result = try await Auth.auth().signIn(withEmail: emailToSignIn, password: password)
            
            // Check verification status
            if !result.user.isEmailVerified {
                print("Login success, but email not verified. Signing out completely.")
                self.errorMessage = "Please verify your email address before logging in."
                try? Auth.auth().signOut()
                return
            }
            
            // Verify profile exists in Firestore
            let profileExists = try await userRepository.doesProfileExist(uid: result.user.uid)
            if !profileExists {
                print("Login: User exists in Auth but not in Firestore. Signing out completely.")
                self.errorMessage = "No Valt profile found. Please create an account."
                try? Auth.auth().signOut()
                return
            }
            
            print("Signed in and verified!")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error signing in: \(error.localizedDescription)")
        }
    }
    
    func signInWithGoogle(presenting viewController: UIViewController) async {
        print("Starting Google Sign In")
        isGoogleLoading = true
        errorMessage = nil
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
            
            let profileExists = try await userRepository.doesProfileExist(uid: authResult.user.uid)
            
            if !profileExists {
                print("Login: No profile found for Google user. Signing out completely.")
                self.errorMessage = "No Valt account found for this Google account. Please sign up first."
                try? Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                return
            }
            
        } catch {
            // Ignore user cancellation errors to keep the UI clean
            if (error as NSError).code != GIDSignInError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func performAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        startAppleSignIn(request: request)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func startAppleSignIn(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        self.currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    private func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authResults):
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8),
                  let nonce = self.currentNonce else { return }
            
            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce,
                accessToken: nil
            )
            
            do {
                let authResult = try await Auth.auth().signIn(with: credential)
                let profileExists = try await userRepository.doesProfileExist(uid: authResult.user.uid)
                
                if !profileExists {
                    self.errorMessage = "No Valt account found for this Apple ID. Please sign up first."
                    try? Auth.auth().signOut()
                    return
                }
            } catch {
                self.errorMessage = error.localizedDescription
                print("Firebase Apple Sign-In Error: \(error.localizedDescription)")
            }
            
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return ASPresentationAnchor()
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            await handleAppleSignInCompletion(result: .success(authorization))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task {
            await handleAppleSignInCompletion(result: .failure(error))
        }
    }
}

enum AuthError: Error { case userNotFound, invalidData }

