import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject var onBoardingViewModel = OnBoardingViewModel()
    @StateObject private var bannerManager = BannerManager()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(settingsViewModel)
                    .environmentObject(bannerManager)
            } else {
                authFlowView
            }
        }
        .preferredColorScheme(settingsViewModel.colorScheme)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }

    @ViewBuilder
    private var authFlowView: some View {
        switch authViewModel.navigationMode {
        case .onboarding:
            OnBoardingView()
                .environmentObject(onBoardingViewModel)
                .environmentObject(authViewModel)
                .transition(.opacity)

        case .login:
            LoginView()
                .environmentObject(authViewModel)
                .environmentObject(bannerManager)
                .transition(.identity)

        case .signup:
            SignUpView()
                .environmentObject(authViewModel)
                .environmentObject(bannerManager)
                .transition(.move(edge: .trailing))
        }
    }
}
