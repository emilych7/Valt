import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated: Bool = false
    @Published var isProfileComplete: Bool = false
    @Published var navigationMode: AppRoute = .onboarding
    @Published var isLoading = false
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    enum AppRoute {
        case onboarding, login, signup
    }

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.currentUser = user
            
            if let user = user {
                // Check if they are a Google user
                let isGoogleUser = user.providerData.contains { $0.providerID == "google.com" }
                
                // If they are Google OR already verified their email
                if isGoogleUser || user.isEmailVerified {
                    self.checkFirestoreProfile(uid: user.uid)
                } else {
                    // Email user who hasn't verified yet
                    self.isAuthenticated = false
                    self.navigationMode = .signup
                    print("Init: User needs email verification")
                }
            } else {
                self.isAuthenticated = false
                print("Init: No user authenticated")
            }
        }
    }
    
    func checkFirestoreProfile(uid: String) {
        print("Checking Firestore Profile...")
        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                if let snapshot = snapshot, snapshot.exists {
                    self.isProfileComplete = true
                    self.isAuthenticated = true
                    print("Profile is complete, signing in...")
                } else {
                    self.isProfileComplete = false
                    self.isAuthenticated = false
                    
                    self.navigationMode = .signup
                    print("Profile is incomplete, staying on onboarding...")
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
        print("Navigating...")
        self.navigationMode = route
    }

    func signOut() {
        print("Signing out...")
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
