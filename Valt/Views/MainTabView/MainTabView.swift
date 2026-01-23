import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var userViewModel = UserViewModel()
    // @State private var showGlobalSettingsOverlay: Bool = false
    @State private var selection: ContentTabViewSelection = .home

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                // Home tab
                HomeView(userViewModel: userViewModel)
                    .tabItem {
                        Label("Create", image: "createIcon")
                    }
                    .tag(ContentTabViewSelection.home)

                // Prompts tab
                ExploreView()
                    .tabItem {
                        Label("Explore", image: "promptsIcon")
                    }
                    .tag(ContentTabViewSelection.explore)

                // Profile tab
                ProfileView(mainTabSelection: $selection)
                    .tag(ContentTabViewSelection.profile)
                    .tabItem {
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
        // Tab Bar styling
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(Color("AppBackgroundColor"))
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color("TextColor"))
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .font: UIFont(name: "OpenSans-Bold", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor(Color("TextColor"))
            ]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .font: UIFont(name: "OpenSans-Bold", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor.systemGray
            ]
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
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

fileprivate extension UIImage {
    func createTabItemLabelFromImage(_ isSelected: Bool) -> UIImage? {
        let imageSize = CGSize(width: 24, height: 24)
        return UIGraphicsImageRenderer(size: imageSize).image { context in
            let rect = CGRect(origin: .init(x: 0, y: 0), size: imageSize)
            let clipPath = UIBezierPath(ovalIn: rect)
            clipPath.addClip()
            self.draw(in: rect)

            if isSelected {
                context.cgContext.setStrokeColor(UIColor.black.cgColor)
                context.cgContext.setLineJoin(.round)
                context.cgContext.setLineCap(.round)
                clipPath.lineWidth = 3
            }
        }.withRenderingMode(.alwaysOriginal)
    }
}
