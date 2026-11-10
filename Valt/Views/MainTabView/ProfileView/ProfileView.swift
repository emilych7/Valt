import SwiftUI
import PhotosUI

@MainActor
struct ProfileView: View {
    @Namespace private var profileNamespace
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var bannerManager: BannerManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Binding var mainTabSelection: ContentTabViewSelection
    
    @State private var selectedDraft: Draft? = nil
    @State private var showNote: Bool = false
    @State private var selectedTab: ProfileTab = .all
    @State private var showSettings: Bool = false
    @State private var showLargeProfilePicture: Bool = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    @State private var isPhotoPickerPresented: Bool = false
    @State private var localProfileImage: UIImage? = nil
    @State private var imageToCrop: UIImage? = nil
    @State private var showCropView: Bool = false
    
    @State private var showingPinEntry = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    MainHeader(title: userViewModel.username, image: "settingsIcon", action: toggleSettings)
                    
                    // Profile Info Section
                    HStack (alignment: .top, spacing: 20) {
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
                        .onLongPressGesture(
                            minimumDuration: 0.35,
                            perform: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    showLargeProfilePicture = true
                                }
                            }
                        )
                        
                        UserInfoView()
                    }
                    .background(Color("AppBackgroundColor"))
                    .padding(.bottom, 15)
                    .padding(.horizontal, 25)
                    
                    ProfileTabView(selectedTab: $selectedTab)
                        .onChange(of: selectedTab) { oldValue, newValue in
                            if newValue == .hidden && !userViewModel.isUnlocked {
                                print("Tab changed to: \(newValue)")
                            }
                        }
                    
                    TabView(selection: $selectedTab) {
                        ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, activeTab: $selectedTab, tab: .all, namespace: profileNamespace)
                            .tag(ProfileTab.all)
                        
                        ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, activeTab: $selectedTab, tab: .favorited, namespace: profileNamespace)
                            .tag(ProfileTab.favorited)
                        
                        ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, activeTab: $selectedTab, tab: .published, namespace: profileNamespace)
                            .tag(ProfileTab.published)
                        
                        Group {
                            if userViewModel.isUnlocked {
                                ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, activeTab: $selectedTab, tab: .hidden, namespace: profileNamespace)
                            } else {
                                LockedTabPlaceholder(action: { // View that asks for the PIN
                                    showingPinEntry = true
                                })
                            }
                        }
                        .tag(ProfileTab.hidden)
                    }
                    .padding(.vertical, 5)
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
                
                if showCropView, let image = imageToCrop {
                    ProfilePhotoCropView(
                        inputImage: image,
                        onCrop: { croppedImage in
                            Task { @MainActor in
                                await userViewModel.uploadProfilePicture(croppedImage)
                                bannerManager.show("Updated Profile Picture", backgroundColor: Color("RequestButtonColor"), icon: "checkmarkIcon")
                            }
                            tabManager.setTabBarHidden(false)
                            withAnimation(.easeOut(duration: 0.2)) {
                                showCropView = false
                                imageToCrop = nil
                                selectedItem = nil
                            }
                        },
                        onCancel: {
                            tabManager.setTabBarHidden(false)
                            withAnimation(.easeOut(duration: 0.2)) {
                                showCropView = false
                                imageToCrop = nil
                                selectedItem = nil
                            }
                        }
                    )
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .fullScreenCover(isPresented: $showLargeProfilePicture) {
                LargeProfilePictureView(profileImage: localProfileImage)
                    .environmentObject(userViewModel)
                    .environmentObject(bannerManager)
                    .environmentObject(tabManager)
                    .presentationBackground(.clear)
            }
            .transaction { transaction in
                if showLargeProfilePicture {
                    transaction.disablesAnimations = true
                }
            }
            .onAppear {
                tabManager.setTabBarHidden(false)
                if !userViewModel.isUnlocked {
                    showingPinEntry = true
                }
                Task {
                    await userViewModel.fetchAuthenticatedUsername()
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { !userViewModel.isUnlocked && selectedTab == .hidden },
                set: { isPresented in
                    if !isPresented && !userViewModel.isUnlocked {
                        selectedTab = .all
                    }
                }
            )) {
                if userViewModel.hasPinSet {
                    PinEntryView(selectedTab: $selectedTab)
                        .environmentObject(userViewModel)
                } else {
                    SetPinView(selectedTab: $selectedTab)
                        .environmentObject(userViewModel)
                }
            }
            .onReceive(userViewModel.$profileImage) { newImage in
                localProfileImage = newImage
            }
            .onChange(of: selectedItem) { _, newValue in
                guard let item = newValue else { return }
                Task { @MainActor in
                    guard let data = try? await item.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else { return }
                    imageToCrop = uiImage
                    tabManager.setTabBarHidden(true)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showCropView = true
                    }
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(selectedDraft: $selectedDraft, showNote: $showNote)
                    .environmentObject(authViewModel)
                    .environmentObject(tabManager)
                    .environmentObject(settingsViewModel)
                    .environmentObject(userViewModel)
                    .environmentObject(bannerManager)
                    .transaction { transaction in
                        transaction.animation = .spring(response: 0.35, dampingFraction: 1.0)
                    }
            }
            .navigationDestination(isPresented: $showNote) {
                if let draft = selectedDraft {
                    FullNoteView(draft: draft, userViewModel: userViewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(tabManager)
                        .environmentObject(bannerManager)
                        .toolbar(.hidden, for: .tabBar)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .environmentObject(tabManager)
        .environmentObject(bannerManager)
        .environmentObject(userViewModel)
        .environmentObject(settingsViewModel)
        .environmentObject(authViewModel)
    }
    
    func toggleSettings() {
        if showSettings != true {
            showSettings = true
        }
    }
}

#Preview("Profile - Active Content") {
    @Previewable @State var tabSelection: ContentTabViewSelection = .profile

    ProfileView(mainTabSelection: $tabSelection)
        .environmentObject(UserViewModel.preview)
        .environmentObject(SettingsViewModel())
        .environmentObject(TabManager())
        .environmentObject(BannerManager())
        .environmentObject(AuthViewModel())
}

#Preview("Profile - Empty State") {
    @Previewable @State var tabSelection: ContentTabViewSelection = .profile

    ProfileView(mainTabSelection: $tabSelection)
        .environmentObject(UserViewModel.previewEmpty)
        .environmentObject(SettingsViewModel())
        .environmentObject(TabManager())
        .environmentObject(BannerManager())
        .environmentObject(AuthViewModel())
}

#Preview("Profile - With Tab Bar") {
    @Previewable @State var selectedDraft: Draft? = nil

    MainTabView(userViewModel: UserViewModel.preview, selectedDraft: $selectedDraft)
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(TabManager())
        .environmentObject(BannerManager())
        .environmentObject(UserViewModel.preview)
}
