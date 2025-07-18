import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showGlobalSettingsOverlay: Bool = false
    @StateObject private var bannerManager = BannerManager()

    init() {
            let appearance = UITabBarAppearance()
        
            appearance.backgroundColor = UIColor(Color("AppBackgroundColor"))
                appearance.shadowImage = UIImage() // Removes the default shadow line
                appearance.shadowColor = .clear

            // Selected items
            appearance.selectionIndicatorImage = UIImage() // Removes default selection indicator
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color("TextColor")) // Selected icon color
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .font: UIFont.customFont(name: "OpenSans-Bold", size: 10) ?? UIFont.systemFont(ofSize: 14, weight: .semibold), // Selected text font
                .foregroundColor: UIColor(Color("TextColor")) // Selected text color
            ]
            
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray// Unselected icon color
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .font: UIFont.customFont(name: "OpenSans-Bold", size: 10) ?? UIFont.systemFont(ofSize: 14, weight: .semibold), // Unselected text font
                .foregroundColor: UIColor.systemGray // Unselected text color
            ]
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    
    var body: some View {
        if authViewModel.isAuthenticated {
            ZStack {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Create", image: "createIcon")
                        }
                    PromptsView()
                        .tabItem {
                            Label("Prompts", image: "promptsIcon")
                        }
                    ProfileView(showSettingsOverlayBinding: $showGlobalSettingsOverlay)
                        .tabItem {
                            Label("Profile", image: "profileIcon")
                            
                        }
                }
                .tint(Color("TextColor"))
                
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
            .environmentObject(bannerManager)
        }
        else {
            OnBoardingView()
                .environmentObject(authViewModel)
        }
    }
    
}
    

extension UIFont {
    static func customFont(name: String, size: CGFloat) -> UIFont? {
        if let font = UIFont(name: name, size: size) {
            return font
        } else {
            print("Warning: Font '\(name)' not found. Using default.")
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
