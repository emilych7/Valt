import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated: Bool = false
    @Published var isProfileComplete: Bool = false
    @Published var navigationMode: AppRoute = .onboarding
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    enum AppRoute {
        case onboarding, login, signup
    }

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.currentUser = user
            
            if let user = user, user.isEmailVerified {
                self.checkFirestoreProfile(uid: user.uid)
            } else {
                self.isAuthenticated = false
            }
        }
    }
    
    func checkFirestoreProfile(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                if let snapshot = snapshot, snapshot.exists {
                    self?.isProfileComplete = true
                    self?.isAuthenticated = true
                } else {
                    self?.isProfileComplete = false
                    self?.isAuthenticated = false
                }
            }
        }
    }

    func finalizeAuthTransition() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.checkFirestoreProfile(uid: uid)
    }
    
    func navigate(to route: AppRoute) {
        self.navigationMode = route
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.isAuthenticated = false
        self.isProfileComplete = false
        self.navigationMode = .onboarding
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
