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
    
    @Published var showForgotPasswordSheet = false
    @Published var resetEmail = ""
    @Published var isSendingReset = false
    @Published var resetErrorMessage: String?
    @Published var resetSuccessMessage: String?
    
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
        super.init()
    }

    func performSignIn() async {
        let uname = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !uname.isEmpty else {
            self.errorMessage = "Username or email is required."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            var emailToSignIn = uname
            
            if emailToSignIn.hasPrefix("@") {
                let cleanUsername = String(emailToSignIn.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                guard let email = try await userRepository.fetchEmailForUsername(cleanUsername) else {
                    throw AuthError.userNotFound
                }
                emailToSignIn = email
            } else if !emailToSignIn.contains("@") {
                let cleanUsername = emailToSignIn.lowercased()
                guard let email = try await userRepository.fetchEmailForUsername(cleanUsername) else {
                    throw AuthError.userNotFound
                }
                emailToSignIn = email
            }
            
            let result = try await Auth.auth().signIn(withEmail: emailToSignIn, password: password)
            
            let profileExists = try await userRepository.doesProfileExist(uid: result.user.uid)
            if !profileExists {
                self.errorMessage = "No Valt profile found. Please create an account."
                try? Auth.auth().signOut()
                return
            }
        } catch {
            if let authError = error as? AuthError, authError == .userNotFound {
                self.errorMessage = "No account found with that username."
            } else {
                var resolvedEmail = uname
                if resolvedEmail.hasPrefix("@") {
                    let clean = String(resolvedEmail.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    if let fetched = try? await userRepository.fetchEmailForUsername(clean) {
                        resolvedEmail = fetched
                    }
                } else if !resolvedEmail.contains("@") {
                    let clean = resolvedEmail.lowercased()
                    if let fetched = try? await userRepository.fetchEmailForUsername(clean) {
                        resolvedEmail = fetched
                    }
                }
                
                if resolvedEmail.contains("@"), let methods = try? await Auth.auth().fetchSignInMethods(forEmail: resolvedEmail), !methods.isEmpty {
                    if methods.contains("google.com") && !methods.contains("password") {
                        self.errorMessage = "This account was created with Google. Please use Google Sign-In, or tap 'Forgot Password' below to set a password."
                    } else if methods.contains("apple.com") && !methods.contains("password") {
                        self.errorMessage = "This account was created with Apple. Please use Apple Sign-In, or tap 'Forgot Password' below to set a password."
                    } else {
                        self.errorMessage = "Incorrect password. Please try again or tap 'Forgot Password'."
                    }
                } else {
                    let nsError = error as NSError
                    if nsError.domain == AuthErrorDomain {
                        if nsError.code == AuthErrorCode.wrongPassword.rawValue || nsError.code == 17004 {
                            self.errorMessage = "Incorrect password. Please try again or tap 'Forgot Password'."
                        } else if nsError.code == AuthErrorCode.userNotFound.rawValue {
                            self.errorMessage = "No account found for that email or username."
                        } else {
                            self.errorMessage = error.localizedDescription
                        }
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func prepareForgotPassword() {
        resetErrorMessage = nil
        resetSuccessMessage = nil
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        resetEmail = trimmed
        showForgotPasswordSheet = true
    }
    
    func sendPasswordReset() async {
        let input = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            resetErrorMessage = "Please enter your email or username."
            return
        }
        
        isSendingReset = true
        resetErrorMessage = nil
        resetSuccessMessage = nil
        defer { isSendingReset = false }
        
        do {
            var targetEmail = input
            if targetEmail.hasPrefix("@") {
                let clean = String(targetEmail.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if let resolved = try await userRepository.fetchEmailForUsername(clean) {
                    targetEmail = resolved
                } else {
                    throw AuthError.userNotFound
                }
            } else if !targetEmail.contains("@") {
                let clean = targetEmail.lowercased()
                if let resolved = try await userRepository.fetchEmailForUsername(clean) {
                    targetEmail = resolved
                } else {
                    throw AuthError.userNotFound
                }
            }
            
            try await Auth.auth().sendPasswordReset(withEmail: targetEmail)
            resetSuccessMessage = "Password reset link sent to \(targetEmail). Check your inbox to create or reset your password."
        } catch {
            if let authError = error as? AuthError, authError == .userNotFound {
                resetErrorMessage = "No account found with that username."
            } else {
                resetErrorMessage = error.localizedDescription
            }
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
            
            _ = try await Auth.auth().signIn(with: credential)
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
                _ = try await Auth.auth().signIn(with: credential)
            } catch {
                self.errorMessage = error.localizedDescription
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

