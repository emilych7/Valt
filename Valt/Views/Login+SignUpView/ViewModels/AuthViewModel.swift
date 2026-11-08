import FirebaseAuth
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated: Bool = false
    @Published var isProfileComplete: Bool = false
    @Published var navigationMode: AppRoute = .onboarding
    @Published var isLoading = false
    
    private let userRepository: UserRepositoryProtocol
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var sessionObserver: NSObjectProtocol?

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
        
        sessionObserver = NotificationCenter.default.addObserver(
            forName: .userSessionInvalidated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.signOut()
            }
        }

        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.currentUser = user
                
                if let user = user {
                    let isFederatedUser = user.providerData.contains { 
                        $0.providerID == "google.com" || $0.providerID == "apple.com" 
                    }
                    
                    if isFederatedUser || user.isEmailVerified {
                        self.checkFirestoreProfile(uid: user.uid)
                    } else {
                        print("Init: User needs email verification. Staying in Signup flow.")
                        self.isAuthenticated = false
                        self.navigationMode = .signup
                    }
                } else {
                    print("User is not authenticated. Ensuring complete sign out.")
                    self.signOut()
                }
            }
        }
    }
    
    func checkFirestoreProfile(uid: String) {
        print("Checking User Profile...")
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let exists = try await self.userRepository.doesProfileExist(uid: uid)
                if exists {
                    self.isProfileComplete = true
                    self.isAuthenticated = true
                    self.navigationMode = .profile
                    print("Profile is complete, signing in...")
                } else {
                    print("Profile is incomplete or does not exist.")
                    if self.navigationMode != .signup {
                        print("User profile missing outside signup. Signing out completely.")
                        self.signOut()
                    } else {
                        self.isProfileComplete = false
                        self.isAuthenticated = false
                        self.navigationMode = .signup
                    }
                }
            } catch {
                print("Error checking profile: \(error.localizedDescription)")
                if error.isUnauthenticatedError {
                    print("User is unauthenticated. Signing out completely.")
                    self.signOut()
                }
            }
        }
    }

    func finalizeAuthTransition() {
        print("Finalizing Auth Transition...")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.checkFirestoreProfile(uid: uid)
    }
    
    func navigate(to route: AppRoute) {
        print("Navigating to \(route)...")
        self.navigationMode = route
    }

    func signOut() {
        print("Signing out completely...")
        
        // 1. Sign out of Google Sign-In
        GIDSignIn.sharedInstance.signOut()
        
        // 2. Sign out of Firebase Auth
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out of Firebase Auth: \(error.localizedDescription)")
        }
        
        // 3. Clear all authentication state
        self.currentUser = nil
        self.isAuthenticated = false
        self.isProfileComplete = false
        self.navigationMode = .onboarding
        self.isLoading = false
        
        // 4. Broadcast sign-out notification so other models can clean up
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        if let observer = sessionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
