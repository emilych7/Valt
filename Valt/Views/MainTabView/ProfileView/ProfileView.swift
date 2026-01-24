import SwiftUI
import PhotosUI

@MainActor
struct ProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Binding var mainTabSelection: ContentTabViewSelection
    @State private var selectedTab: ProfileTab = .all
    @State private var showSettings: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isPhotoPickerPresented: Bool = false
    @State private var localProfileImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header Section
                MainHeader(title: "My Valt", image: "settingsIcon", action: toggleSettings)
                
                // Profile Info Section
                HStack {
                    AvatarView(
                        loadingState: userViewModel.userLoadingState,
                        profileImage: localProfileImage
                    )
                    .onTapGesture { isPhotoPickerPresented = true }
                    .photosPicker(
                        isPresented: $isPhotoPickerPresented,
                        selection: $selectedItem,
                        matching: .images
                    )
                    
                    UserInfoView(userViewModel: userViewModel)
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.vertical, 15)
                
                ProfileTabView(selectedTab: $selectedTab)
                    .padding(.horizontal, 15)
                
                TabView(selection: $selectedTab) {
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, tab: .all)
                        .tag(ProfileTab.all)
                    
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, tab: .favorited)
                        .tag(ProfileTab.favorited)
                    
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, tab: .published)
                        .tag(ProfileTab.published)
                    
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, tab: .hidden)
                        .tag(ProfileTab.hidden)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.horizontal, 20)
            }
            .background(Color("AppBackgroundColor").ignoresSafeArea())
        }
        .onReceive(userViewModel.$profileImage) { newImage in
            localProfileImage = newImage
        }
        .onChange(of: selectedItem) { _, newValue in
            Task {
                guard let item = newValue,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                await userViewModel.uploadProfilePicture(uiImage)
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    func toggleSettings() {
        if showSettings != true {
            showSettings = true
        }
    }
}
