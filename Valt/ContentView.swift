import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var bannerManager = BannerManager()
    @StateObject private var userViewModel = UserViewModel()

    var body: some View {
        if authViewModel.isAuthenticated {
            MainTabView()
                .environmentObject(authViewModel)
                .environmentObject(userViewModel)
                .environmentObject(bannerManager)
        } else {
            OnBoardingView()
                .environmentObject(authViewModel)
        }
    }
}
