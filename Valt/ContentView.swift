import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject var onBoardingViewModel = OnBoardingViewModel()
    @StateObject private var bannerManager = BannerManager()
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var tabManager = TabManager()
    @State private var selectedDraft: Draft? = nil

    private var isAuthSheetPresented: Binding<Bool> {
        Binding<Bool>(
            get: {
                authViewModel.navigationMode == .login || authViewModel.navigationMode == .signup
            },
            set: { isPresented in
                if !isPresented {
                    if authViewModel.navigationMode == .login || authViewModel.navigationMode == .signup {
                        authViewModel.navigate(to: .onboarding)
                    }
                }
            }
        )
    }

    var body: some View {
        Group {
            ZStack {
                if userViewModel.userLoadingState == .loading && authViewModel.isAuthenticated {
                    loadingOverlay
                }
                authFlowView
            }
        }
        .preferredColorScheme(settingsViewModel.colorScheme)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .background(Color("AppBackgroundColor"))
        .environmentObject(tabManager)
        .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
            selectedDraft = nil
            tabManager.setTabBarHidden(false)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color("AppBackgroundColor")
                .ignoresSafeArea()
            
            ValtAnimatedLogo(size: 84, isSpinning: true)
        }
        .transition(.opacity)
        .zIndex(1)
    }

    @ViewBuilder
    private var authFlowView: some View {
        ZStack {
            if authViewModel.navigationMode == .profile {
                MainTabView(userViewModel: userViewModel, selectedDraft: $selectedDraft)
                    .environmentObject(authViewModel)
                    .environmentObject(settingsViewModel)
                    .environmentObject(bannerManager)
                    .environmentObject(userViewModel)
                    .environmentObject(tabManager)
            } else {
                OnBoardingView()
                    .environmentObject(onBoardingViewModel)
                    .environmentObject(authViewModel)
                    .environmentObject(userViewModel)
            }
        }
        .sheet(isPresented: isAuthSheetPresented) {
            authSheetView
                .presentationDetents([.fraction(0.93)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .preferredColorScheme(settingsViewModel.colorScheme)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: authViewModel.navigationMode == .profile)
    }

    @ViewBuilder
    private var authSheetView: some View {
        Group {
            if authViewModel.navigationMode == .login {
                LoginView()
                    .environmentObject(authViewModel)
                    .environmentObject(bannerManager)
                    .environmentObject(userViewModel)
            } else {
                SignUpView(userViewModel: userViewModel)
                    .environmentObject(authViewModel)
                    .environmentObject(bannerManager)
                    .environmentObject(userViewModel)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authViewModel.navigationMode)
    }
}
