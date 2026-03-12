import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject var onBoardingViewModel = OnBoardingViewModel()
    @StateObject private var bannerManager = BannerManager()
    @StateObject private var userViewModel = UserViewModel()
    @State private var selectedDraft: Draft? = nil

    var body: some View {
        Group {
            ZStack {
                if userViewModel.userLoadingState == .loading {
                    loadingOverlay
                }
                authFlowView
            }
        }
        .preferredColorScheme(settingsViewModel.colorScheme)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .background(Color("AppBackgroundColor"))
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color("AppBackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                ProgressView()
                    .controlSize(.regular)
                    .tint(Color("TextColor"))
            }
        }
        .transition(.opacity)
        .zIndex(1)
    }

    @ViewBuilder
    private var authFlowView: some View {
        ZStack {
            switch authViewModel.navigationMode {
                case .onboarding:
                    OnBoardingView()
                        .environmentObject(onBoardingViewModel)
                        .environmentObject(authViewModel)
                        .environmentObject(userViewModel)

                case .login:
                    LoginView()
                        .environmentObject(authViewModel)
                        .environmentObject(bannerManager)
                        .environmentObject(userViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .bottom)
                        ))

                case .signup:
                    SignUpView(userViewModel: userViewModel)
                        .environmentObject(authViewModel)
                        .environmentObject(bannerManager)
                        .environmentObject(userViewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .bottom)
                    ))
                case .profile:
                    MainTabView(userViewModel: userViewModel, selectedDraft: $selectedDraft)
                        .environmentObject(authViewModel)
                        .environmentObject(settingsViewModel)
                        .environmentObject(bannerManager)
                        .environmentObject(userViewModel)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: authViewModel.navigationMode)
    }
}
