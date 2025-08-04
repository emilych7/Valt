import SwiftUI

struct ContentView: View {
    // Top-level state objects initialized here
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var bannerManager = BannerManager()
    @StateObject private var userVM = UserViewModel()

    var body: some View {
        if authViewModel.isAuthenticated {
            MainTabView(
                authViewModel: authViewModel,
                userVM: userVM,
                bannerManager: bannerManager
            )
        } else {
            OnBoardingView()
                .environmentObject(authViewModel)
        }
    }
}
