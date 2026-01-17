import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject var settingsViewModel = SettingsViewModel()
    @StateObject private var bannerManager = BannerManager()
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var onBoardingViewModel = OnBoardingViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(userViewModel)
                    .environmentObject(bannerManager)
                    .environmentObject(settingsViewModel)
            } else {
                OnBoardingView()
                    .environmentObject(authViewModel)
                    .environmentObject(onBoardingViewModel)
            }
        }
        .preferredColorScheme(settingsViewModel.colorScheme)
    }
}



