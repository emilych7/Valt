import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var tabManager = TabManager()
    @StateObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selection: ContentTabViewSelection = .home
    
    init(userViewModel: UserViewModel, selectedDraft: Binding<Draft?>) {
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
        _selection = State(initialValue: .home)
    }

    var body: some View {
        ZStack {
            // Content Layer
            Group {
                switch selection {
                    case .home:
                        HomeView(viewModel: homeViewModel)
                    case .explore:
                        ExploreView()
                    case .profile:
                        ProfileView(mainTabSelection: $selection)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !tabManager.isTabBarHidden {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color("TextColor").opacity(0.1))
                            .frame(height: 1)
                        
                        CustomTabBar(selection: $selection, userViewModel: userViewModel)
                            .background(Color("AppBackgroundColor"))
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .environmentObject(tabManager)
        .overlay(alignment: .top) {
            if bannerManager.isVisible {
                notificationBanner
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
            }
        }
    }

    private var notificationBanner: some View {
        HStack(spacing: 8) {
            if let icon = bannerManager.icon {
                Image(icon)
                    .foregroundColor(.white)
            }
            Text(bannerManager.message)
                .foregroundColor(.white)
                .font(.custom("OpenSans-Regular", size: 15))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 10).fill(bannerManager.backgroundColor))
        .shadow(radius: 2)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct CustomTabBar: View {
    @Binding var selection: ContentTabViewSelection
    @ObservedObject var userViewModel: UserViewModel
    
    let iconSize: CGFloat = 25
    let profileSize: CGFloat = 25

    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabButton(
                title: "Create",
                imageName: "createIcon",
                tab: .home,
                selection: $selection,
                size: iconSize
            )
            // Explore Tab
            TabButton(
                title: "Explore",
                imageName: "promptsIcon",
                tab: .explore,
                selection: $selection,
                size: iconSize
            )
            // Profile Tab
            Button(action: { selection = .profile }) {
                VStack(spacing: 6) {
                    profileIcon
                    Text("Profile")
                        .font(.custom("OpenSans-SemiBold", size: 11))
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selection == .profile ? Color("TextColor") : Color("TextColor").opacity(0.4))
            }
        }
        .padding(.top, 10)   // Top padding for the icons
        .padding(.bottom, 5) // Bottom padding (distance away from home slider)
    }

    @ViewBuilder
    private var profileIcon: some View {
        switch userViewModel.profileLoadingState {
        case .loading:
            ZStack {
                Circle().fill(Color("BubbleColor")).frame(width: profileSize, height: profileSize)
                ProgressView().scaleEffect(0.6).tint(Color("ReverseTextColor"))
            }
        case .complete:
            if let image = userViewModel.profileImage?.createTabItemLabelFromImage(selection == .profile) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: profileSize, height: profileSize)
                    .clipShape(Circle())
            } else {
                defaultProfileIcon
            }
        case .error, .empty:
            defaultProfileIcon
        }
    }

    private var defaultProfileIcon: some View {
        Circle()
            .fill(Color("BubbleColor").opacity(selection == .profile ? 1.0 : 0.4))
            .frame(width: profileSize, height: profileSize)
    }
}

struct TabButton: View {
    let title: String
    let imageName: String
    let tab: ContentTabViewSelection
    @Binding var selection: ContentTabViewSelection
    let size: CGFloat

    var body: some View {
        Button(action: { selection = tab }) {
            VStack(spacing: 6) {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                
                Text(title)
                    .font(.custom("OpenSans-SemiBold", size: 11))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selection == tab ? Color("TextColor") : Color("TextColor").opacity(0.4))
        }
        .buttonStyle(.plain)
    }
}
