import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var tabManager: TabManager
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @StateObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selection: ContentTabViewSelection = .profile
    @State private var dragOffset: CGFloat = 0.0
    
    init(userViewModel: UserViewModel, selectedDraft: Binding<Draft?>) {
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(userViewModel: userViewModel))
        _selection = State(initialValue: .profile)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        ExploreView(homeViewModel: homeViewModel)
                            .frame(width: screenWidth, height: screenHeight)
                        
                        NewDraftView(userViewModel: userViewModel, isActive: selection == .home)
                            .frame(width: screenWidth, height: screenHeight)
                        
                        ProfileView(mainTabSelection: $selection)
                            .frame(width: screenWidth, height: screenHeight)
                    }
                    .frame(width: screenWidth * 3, height: screenHeight, alignment: .leading)
                    .offset(x: -CGFloat(selection.index) * screenWidth + dragOffset)
                }
                .frame(width: screenWidth, height: screenHeight, alignment: .leading)
                .clipped()
                .animation(.spring(response: 0.32, dampingFraction: 0.86), value: selection)
                .onScreenEdgeSwipe(
                    canSwipeLeft: selection.next != nil,
                    canSwipeRight: selection.previous != nil,
                    onDragChanged: { offset in
                        dragOffset = offset
                    },
                    onDragEnded: { offset, velocity in
                        handleDragEnded(offset: offset, velocity: velocity, screenWidth: screenWidth)
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard, edges: tabManager.isTabBarHidden ? .bottom : [])
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !tabManager.isTabBarHidden {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color("TextColor").opacity(0.1))
                            .frame(height: 1)
                        
                        CustomTabBar(selection: $selection, userViewModel: userViewModel)
                            .background(Color("AppBackgroundColor"))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onChange(of: selection) { _, _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .environmentObject(tabManager)
        .environmentObject(bannerManager)
        .environmentObject(userViewModel)
        .environmentObject(authViewModel)
        .environmentObject(settingsViewModel)
        .overlay(alignment: .top) {
            if bannerManager.isVisible {
                notificationBanner
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
            }
        }
    }

    private func handleDragEnded(offset: CGFloat, velocity: CGFloat, screenWidth: CGFloat) {
        let threshold = max(50, screenWidth * 0.22)
        
        if let prev = selection.previous, (offset > threshold || velocity > 260) && velocity >= -180 {
            triggerHaptic()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                selection = prev
                dragOffset = 0
            }
        } else if let next = selection.next, (offset < -threshold || velocity < -260) && velocity <= 180 {
            triggerHaptic()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                selection = next
                dragOffset = 0
            }
        } else {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                dragOffset = 0
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
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
            TabButton(
                title: "Explore",
                imageName: "promptsIcon",
                tab: .explore,
                selection: $selection,
                size: iconSize
            )
            TabButton(
                title: "Create",
                imageName: "createIcon",
                tab: .home,
                selection: $selection,
                size: iconSize
            )
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    selection = .profile
                }
            }) {
                VStack(spacing: 6) {
                    profileIcon
                    Text("Profile")
                        .font(.custom("OpenSans-SemiBold", size: 11))
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selection == .profile ? Color("TextColor") : Color("TextColor").opacity(0.4))
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
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
        Button(action: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                selection = tab
            }
        }) {
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
