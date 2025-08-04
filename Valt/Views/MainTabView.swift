import SwiftUI
import UIKit

struct MainTabView: View {
    // Passed in from ContentView
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var userVM: UserViewModel
    @StateObject private var bannerManager: BannerManager
    
    @State private var showGlobalSettingsOverlay: Bool = false
    @State private var selection: ContentTabViewSelection = .profile

    @Environment(\.colorScheme) var colorScheme

    init(authViewModel: AuthViewModel, userVM: UserViewModel, bannerManager: BannerManager) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        _userVM = StateObject(wrappedValue: userVM)
        _bannerManager = StateObject(wrappedValue: bannerManager)

        // UITabBarAppearance setup
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

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                // Home tab
                HomeView()
                    .tabItem {
                        Label("Create", image: "createIcon")
                    }
                    .tag(ContentTabViewSelection.home)

                // Prompts tab
                PromptsView()
                    .tabItem {
                        Label("Prompts", image: "promptsIcon")
                    }
                    .tag(ContentTabViewSelection.prompts)

                // Profile tab
                ProfileView(showSettingsOverlayBinding: $showGlobalSettingsOverlay)
                    .tag(ContentTabViewSelection.profile)
                    .environmentObject(userVM)
                    .tabItem {
                        profileTabItemLabel()
                    }
            }
            .tint(Color("TextColor"))
            .environmentObject(authViewModel)
            .environmentObject(bannerManager)
            .environmentObject(userVM)

            // Settings Overlay
            ZStack {
                if showGlobalSettingsOverlay {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showGlobalSettingsOverlay = false
                            }
                        }
                        .transition(.opacity)
                }

                if showGlobalSettingsOverlay {
                    SettingsView(isShowingOverlay: $showGlobalSettingsOverlay)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .environmentObject(authViewModel)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showGlobalSettingsOverlay)

            // Banner Manager
            if bannerManager.isVisible {
                VStack {
                    Text(bannerManager.message)
                        .font(.custom("OpenSans-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(8)
                        .padding(.top, 50)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(2)
            }
        }
    }
    
    // Profile pic tab and label
    private func profileTabItemLabel() -> some View {
        ZStack {
            Label {
                Text("Profile")
            } icon: {
                if let profilePicture = (userVM.profilePicture)?.createTabItemLabelFromImage(selection == .profile) {
                    Image(uiImage: profilePicture)
                } else {
                    ContentTabViewSelection.profile.label
                }
            }
        }
        .animation(.none, value: colorScheme)
    }
}


// Helper extension
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
                clipPath.stroke()
            }
        }.withRenderingMode(.alwaysOriginal)
    }
}
