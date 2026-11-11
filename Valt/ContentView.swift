import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject var onBoardingViewModel = OnBoardingViewModel()
    @StateObject private var bannerManager = BannerManager()
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var tabManager = TabManager()
    @State private var selectedDraft: Draft? = nil
    @State private var hasMinimumSplashElapsed: Bool = false

    private var isAppLoading: Bool {
        if !hasMinimumSplashElapsed {
            return true
        }
        if !authViewModel.isInitialCheckComplete {
            return true
        }
        if authViewModel.isAuthenticated && userViewModel.userLoadingState == .loading {
            return true
        }
        return false
    }

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
                if !isAppLoading {
                    authFlowView
                        .transition(.opacity)
                }
                
                if isAppLoading {
                    loadingOverlay
                        .transition(.opacity)
                }
            }
        }
        .preferredColorScheme(settingsViewModel.colorScheme)
        .animation(.easeInOut(duration: 0.35), value: isAppLoading)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .background(Color("AppBackgroundColor"))
        .environmentObject(tabManager)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    hasMinimumSplashElapsed = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
            selectedDraft = nil
            tabManager.setTabBarHidden(false)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color("AppBackgroundColor")
            
            ValtAnimatedLogo(
                size: 150,
                isSpinning: true,
                spinDuration: 10.0,
                isPulsing: true,
                isActive: true
            )
        }
        .ignoresSafeArea()
        .transition(.opacity)
        .zIndex(10)
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
        .sheet(isPresented: isAuthSheetPresented, onDismiss: {
            if let nextRoute = authViewModel.pendingAuthRoute {
                authViewModel.pendingAuthRoute = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    authViewModel.navigate(to: nextRoute)
                }
            }
        }) {
            authSheetView
                .presentationSizing(FullWidthPresentationSizing())
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(Color("AppBackgroundColor"))
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

struct FullWidthPresentationSizing: PresentationSizing {
    func proposedSize(for root: PresentationSizingRoot, context: PresentationSizingContext) -> ProposedViewSize {
        ProposedViewSize(width: .infinity, height: nil)
    }
}

