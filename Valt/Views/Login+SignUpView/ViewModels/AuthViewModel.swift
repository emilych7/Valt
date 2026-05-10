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

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.currentUser = user
            
            if let user = user {
                let isGoogleUser = user.providerData.contains { $0.providerID == "google.com" }
                
                if isGoogleUser || user.isEmailVerified {
                    self.checkFirestoreProfile(uid: user.uid)
                } else {
                    print("Init: User needs email verification. Staying in Signup flow.")
                    self.isAuthenticated = false
                    self.navigationMode = .signup
                }
            } else {
                print("User is not authenticated.")
                self.isAuthenticated = false
                self.isProfileComplete = false
                self.navigationMode = .onboarding
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
                    self.navigationMode = .profile
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
        
        self.isProfileComplete = false
        self.navigationMode = .onboarding
        
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
