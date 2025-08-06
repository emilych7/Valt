import SwiftUI
import UIKit

struct MainTabView: View {
    // These should be @EnvironmentObject, not @StateObject
    // This tells SwiftUI to get the objects from the parent's environment.
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    
    @State private var showGlobalSettingsOverlay: Bool = false
    @State private var selection: ContentTabViewSelection = .profile

    @Environment(\.colorScheme) var colorScheme

    // The custom initializer is no longer needed.
    // The UITabBarAppearance setup can be moved to an .onAppear modifier,
    // or placed in your App struct's init() to run only once.
    
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
                PromptsView()
                    .tabItem {
                        Label("Prompts", image: "promptsIcon")
                    }
                    .tag(ContentTabViewSelection.prompts)

                // Profile tab
                ProfileView(showSettingsOverlayBinding: $showGlobalSettingsOverlay)
                    .tag(ContentTabViewSelection.profile)
                    // You don't need to pass the environment object here if it's already on a parent view
                    // .environmentObject(userViewModel)
                    .tabItem {
                        profileTabItemLabel()
                    }
            }
            .tint(Color("TextColor"))
            // These environment objects are now inherited from ContentView,
            // so they don't need to be re-injected here.
            // .environmentObject(authViewModel)
            // .environmentObject(bannerManager)
            // .environmentObject(userViewModel)

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
                        // The environment object is available from the parent, no need to re-inject.
                        // .environmentObject(authViewModel)
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
        // This is a good place to put your one-time UI setup if you don't have
        // an init().
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
