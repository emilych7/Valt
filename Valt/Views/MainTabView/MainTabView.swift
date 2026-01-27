import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var userViewModel = UserViewModel()
    @State private var selection: ContentTabViewSelection = .home
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
            // Content Layer
            Group {
                switch selection {
                case .explore:
                    ExploreView(userViewModel: userViewModel)
                case .home:
                    HomeView(userViewModel: userViewModel)
                case .profile:
                    ProfileView(mainTabSelection: $selection)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color("TextColor").opacity(0.1))
                        .frame(height: 1)
                    
                    CustomTabBar(selection: $selection, userViewModel: userViewModel)
                        .background(Color("AppBackgroundColor"))
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .overlay {
                if bannerManager.isVisible {
                    notificationBanner
                }
            }
    }

    private var notificationBanner: some View {
        VStack {
            Spacer().frame(height: 300)
            HStack(spacing: 8) {
                if let icon = bannerManager.icon {
                    Image(systemName: icon).foregroundColor(.white)
                }
                Text(bannerManager.message)
                    .foregroundColor(.white)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14).fill(bannerManager.backgroundColor))
            .padding(.horizontal, 40)
            .shadow(radius: 8)
            Spacer()
        }
        .transition(.scale.combined(with: .opacity))
    }
}

struct CustomTabBar: View {
    @Binding var selection: ContentTabViewSelection
    @ObservedObject var userViewModel: UserViewModel
    
    let iconSize: CGFloat = 25
    let profileSize: CGFloat = 25

    var body: some View {
        HStack(spacing: 0) {
            // Explore Tab
            TabButton(
                title: "Explore",
                imageName: "promptsIcon",
                tab: .explore,
                selection: $selection,
                size: iconSize
            )

            // Home Tab
            TabButton(
                title: "Create",
                imageName: "createIcon",
                tab: .home,
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
            .fill(Color("TextColor").opacity(selection == .profile ? 1.0 : 0.4))
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
