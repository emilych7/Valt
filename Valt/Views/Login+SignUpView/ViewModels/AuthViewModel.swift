import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated: Bool = false
    @Published var navigationMode: AppRoute = .onboarding
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    enum AppRoute {
        case onboarding, login, signup
    }

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAuthenticated = (user != nil)
        }
    }
    
    func navigate(to route: AppRoute) {
        self.navigationMode = route
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.navigationMode = .onboarding
    }
    
    deinit {
            if let handle = authHandle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
}
