import Foundation
import FirebaseFirestore
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

    private let db = Firestore.firestore()
    private let userViewModel: UserViewModel
    
    var canSubmitStep1: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == passwordConfirmation &&
        AuthValidator.isValidPassword(password)
    }
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        super.init()
        
        if let user = Auth.auth().currentUser {
            let isGoogle = user.providerData.contains { $0.providerID == "google.com" }
            
            if !isGoogle && !user.isEmailVerified {
                self.email = user.email ?? ""
                self.currentStep = .emailVerification
                self.startVerificationPolling()
            } else if isGoogle || user.isEmailVerified {
                self.email = user.email ?? ""
                self.currentStep = .chooseUsername
            }
        }
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
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            Task { @MainActor in
                try? await Auth.auth().currentUser?.reload()
                
                if let user = Auth.auth().currentUser, user.isEmailVerified {
                    timer.invalidate()
                    self.currentStep = .chooseUsername
                }
            }
        }
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
            let usernameRef = db.collection("usernames").document(uname)
            let snapshot = try await usernameRef.getDocument()
            
            if snapshot.exists {
                self.errorMessage = "This username is already taken."
                isLoading = false
                return
            }
            
            guard let currentUser = Auth.auth().currentUser else { return }
            
            let batch = db.batch()
            let userRef = db.collection("users").document(currentUser.uid)
            let userData: [String: Any] = [
                "userID": currentUser.uid,
                "email": Auth.auth().currentUser?.email ?? self.email,
                "username": uname,
                "createdAt": FieldValue.serverTimestamp()
            ]
            batch.setData(userData, forDocument: userRef)
            batch.setData(["userID": currentUser.uid], forDocument: usernameRef)
            
            try await batch.commit()
            
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
            
            // Small delay to let the UIKit pop-up dismiss smoothly
            try await Task.sleep(nanoseconds: 600_000_000)

            // Check if user already have a Firestore profile
            let userDoc = try await db.collection("users").document(authResult.user.uid).getDocument()
            
            if userDoc.exists {
                // Returning User
                print("Google Login Success: User exists in Firestore.")
                self.isSignupComplete = true
            } else {
                // New User/Incomplete Profile
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
                // If this is the user's first time, appleIDCredential.fullName will have data
                if let name = appleIDCredential.fullName {
                    // Save name to Firestore here
                }
            } catch {
                print("Firebase Apple Sign-In Error: \(error.localizedDescription)")
            }
            
        case .failure(let error):
            print("Apple Sign-In failed: \(error.localizedDescription)")
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

    // Triggers when the user successfully authenticates with FaceID/TouchID (will add later)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            await handleAppleSignInCompletion(result: .success(authorization))
        }
    }

    // Triggers if the user cancels or an error occurs
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task {
            await handleAppleSignInCompletion(result: .failure(error))
        }
    }
}
