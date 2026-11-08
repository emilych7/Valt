import Foundation
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

@MainActor
class SignUpViewModel: NSObject, ObservableObject {
    enum SignupStep { case accountDetails, emailVerification, chooseUsername }
    enum Field { case email, password, passwordConfirmation, username }
    
    @Published var currentStep: SignupStep = .accountDetails
    
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var usernameBorderColor = "TextColor"
    @Published var passwordBorderColor = "TextColor"
    
    @Published var isLoading = false
    @Published var isGoogleLoading = false
    @Published var errorMessage: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var isSignupComplete = false
    @Published var currentNonce: String?
    
    private let userRepository: UserRepositoryProtocol
    private let userViewModel: UserViewModel
    private var verificationTimer: Timer?
    
    var canSubmitStep1: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == passwordConfirmation &&
        AuthValidator.isValidPassword(password)
    }
    
    init(userViewModel: UserViewModel, userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userViewModel = userViewModel
        self.userRepository = userRepository
        super.init()
    }
    
    func validateAndStartSignup() async {
        errorMessage = nil
        passwordError = nil
        
        if password != passwordConfirmation {
            passwordError = "Passwords do not match."
            print("Passwords do not match.")
            ValidationErrorTip.passwordHasError = true
            return
        }
        
        if !AuthValidator.isValidPassword(password) {
            let missing = AuthValidator.getMissingValidation(password)
            passwordBorderColor = "ValtRed"
            passwordError = "Password missing: \(missing.joined(separator: ", "))"
            print("Error: \(missing.joined(separator: ", "))")
            ValidationErrorTip.passwordHasError = true
            return
        }
        
        ValidationErrorTip.passwordHasError = false
        await createAccountAndVerify()
    }
    
    private func createAccountAndVerify() async {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()
            print("Going to email verification step.")
            self.currentStep = .emailVerification
            startVerificationPolling()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func startVerificationPolling() {
        print("Starting verification timer...")
        verificationTimer?.invalidate()
        verificationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                try? await Auth.auth().currentUser?.reload()
                if let user = Auth.auth().currentUser, user.isEmailVerified {
                    timer.invalidate()
                    self?.verificationTimer = nil
                    self?.currentStep = .chooseUsername
                }
            }
        }
    }
    
    func stopVerificationPolling() {
        verificationTimer?.invalidate()
        verificationTimer = nil
    }
    
    func resendEmail() {
        print("Resending email...")
        Task {
            do {
                try await Auth.auth().currentUser?.sendEmailVerification()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func finalizeUsername() async {
        let uname = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !uname.isEmpty else {
            self.errorMessage = "Username is required."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard let currentUser = Auth.auth().currentUser else { return }
            let emailToUse = currentUser.email ?? self.email
            try await userRepository.createProfile(uid: currentUser.uid, username: uname, email: emailToUse)
            self.isSignupComplete = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        print("Starting Google Sign Up")
        isGoogleLoading = true
        errorMessage = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            self.errorMessage = "Internal UI Error"
            isGoogleLoading = false
            return
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let credential = GoogleAuthProvider.credential(withIDToken: result.user.idToken?.tokenString ?? "",
                                                           accessToken: result.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            try await Task.sleep(nanoseconds: 600_000_000)
            
            let profileExists = try await userRepository.doesProfileExist(uid: authResult.user.uid)
            
            if profileExists {
                print("Google Login Success: User exists in Firestore.")
                self.isSignupComplete = true
            } else {
                print("Google Signup Success: No profile found. Moving to Username step.")
                self.email = authResult.user.email ?? ""
                self.currentStep = .chooseUsername
            }
            
        } catch {
            if (error as NSError).code != GIDSignInError.canceled.rawValue {
                self.errorMessage = error.localizedDescription
            }
        }
        isGoogleLoading = false
    }
    
    func startAppleSignIn(request: ASAuthorizationAppleIDRequest) {
        print("Starting Apple Sign In")
        let nonce = randomNonceString()
        self.currentNonce = nonce
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) async {
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
                
                if profileExists {
                    self.isSignupComplete = true
                } else {
                    self.email = authResult.user.email ?? ""
                    
                    if let name = appleIDCredential.fullName {
                        print("Apple Username: \(name.givenName ?? "")")
                    }
                    
                    self.currentStep = .chooseUsername
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
    
    func performAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        self.startAppleSignIn(request: request)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension SignUpViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
