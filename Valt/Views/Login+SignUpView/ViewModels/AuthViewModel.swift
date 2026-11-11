import FirebaseAuth
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated: Bool = false
    @Published var isProfileComplete: Bool = false
    @Published var navigationMode: AppRoute = .onboarding
    @Published var pendingAuthRoute: AppRoute? = nil
    @Published var isLoading = false
    @Published var isInitialCheckComplete = false
    
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
                    self.checkFirestoreProfile(uid: user.uid)
                } else {
                    self.currentUser = nil
                    self.isAuthenticated = false
                    self.isProfileComplete = false
                    self.navigationMode = .onboarding
                    self.isLoading = false
                    self.isInitialCheckComplete = true
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            if !self.isInitialCheckComplete {
                self.isInitialCheckComplete = true
            }
        }
    }
    
    func checkFirestoreProfile(uid: String) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let exists = try await self.userRepository.doesProfileExist(uid: uid)
                if exists {
                    self.isProfileComplete = true
                    self.isAuthenticated = true
                    self.navigationMode = .profile
                } else {
                    self.isProfileComplete = false
                    self.isAuthenticated = false
                    self.navigationMode = .signup
                }
            } catch {
                if error.isUnauthenticatedError {
                    self.signOut()
                }
            }
            self.isInitialCheckComplete = true
        }
    }

    func finalizeAuthTransition() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.checkFirestoreProfile(uid: uid)
    }
    
    func navigate(to route: AppRoute) {
        self.navigationMode = route
    }

    func switchAuthSheet(to route: AppRoute) {
        if navigationMode == .login || navigationMode == .signup {
            pendingAuthRoute = route
            navigationMode = .onboarding
        } else {
            navigationMode = route
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        
        self.currentUser = nil
        self.isAuthenticated = false
        self.isProfileComplete = false
        self.navigationMode = .onboarding
        self.isLoading = false
        
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
