import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var userViewModel = UserViewModel()
    @State private var selection: ContentTabViewSelection = .home

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                // Home tab
                HomeView(userViewModel: userViewModel)
                    .tabItem {
                        Label(" ", image: "createIcon")
                    }
                    .tag(ContentTabViewSelection.home)

                // Prompts tab
                ExploreView(userViewModel: userViewModel)
                    .tabItem {
                        Label(" ", image: "promptsIcon")
                    }
                    .tag(ContentTabViewSelection.explore)

                // Profile tab
                ProfileView(mainTabSelection: $selection)
                    .tabItem { profileTabItemLabel() }
                    .tag(ContentTabViewSelection.profile)
            }
            .padding(.top, 5)
            .tint(Color("TextColor"))
            .environmentObject(userViewModel)
            
            // Notification banner
            if bannerManager.isVisible {
                    VStack {
                        Spacer()
                            .frame(height: 300)
                        
                        HStack(spacing: 8) {
                            if let icon = bannerManager.icon {
                                Image(systemName: icon)
                                    .foregroundColor(.white)
                            }
                            Text(bannerManager.message)
                                .foregroundColor(.white)
                                .font(.custom("OpenSans-Regular", size: 15))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(bannerManager.backgroundColor)
                        )
                        .padding(.horizontal, 40)
                        .shadow(radius: 8)
                        
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
        }
        .applyTabBarAppearance()
    }
    
    // Profile pic tab and label
    private func profileTabItemLabel() -> some View {
        ZStack {
            Label {
                Text("Profile")
            } icon: {
                if let profilePicture = (userViewModel.profileImage)?.createTabItemLabelFromImage(selection == .profile) {
                    Image(uiImage: profilePicture)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                } else {
                    ContentTabViewSelection.profile.label
                }
            }
        }
        .animation(.none, value: colorScheme)
    }
}
