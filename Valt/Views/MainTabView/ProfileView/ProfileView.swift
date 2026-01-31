import SwiftUI
import PhotosUI

@MainActor
struct ProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Binding var mainTabSelection: ContentTabViewSelection
    @Binding var selectedDraft: Draft?
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
                    Avatar(
                        loadingState: userViewModel.profileLoadingState,
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
                .padding(.bottom, 15)
                .padding(.horizontal, 25)
                
                ProfileTabView(selectedTab: $selectedTab)
                
                TabView(selection: $selectedTab) {
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, tab: .all)
                        .tag(ProfileTab.all)
                    
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, tab: .favorited)
                        .tag(ProfileTab.favorited)
                    
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, tab: .published)
                        .tag(ProfileTab.published)
                    
                    ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, tab: .hidden)
                        .tag(ProfileTab.hidden)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color("TextFieldBackground").opacity(0.7))
                .onAppear {
                    UIScrollView.appearance().bounces = false
                }
                .onDisappear {
                    UIScrollView.appearance().bounces = true
                }
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
