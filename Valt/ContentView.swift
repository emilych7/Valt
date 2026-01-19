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
        ZStack {
            switch authViewModel.navigationMode {
            case .onboarding:
                OnBoardingView()
                    .environmentObject(onBoardingViewModel)
                    .environmentObject(authViewModel)

            case .login:
                LoginView()
                    .environmentObject(authViewModel)
                    .environmentObject(bannerManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .bottom)
                    ))

            case .signup:
                SignUpView()
                    .environmentObject(authViewModel)
                    .environmentObject(bannerManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .bottom)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: authViewModel.navigationMode)
    }
}
