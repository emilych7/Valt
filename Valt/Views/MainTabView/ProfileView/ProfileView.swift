import SwiftUI
import PhotosUI

@MainActor
struct ProfileView: View {
    @Namespace private var profileNamespace
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Binding var mainTabSelection: ContentTabViewSelection
    @State private var selectedDraft: Draft? = nil
    @State private var showNote: Bool = false
    @State private var selectedTab: ProfileTab = .all
    @State private var showSettings: Bool = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    @State private var isPhotoPickerPresented: Bool = false
    @State private var localProfileImage: UIImage? = nil
    
    @State private var isHiddenUnlocked = false
    @State private var showingPinEntry = false
    
    var body: some View {
        NavigationStack {
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
                        
                        UserInfoView()
                        
                        Spacer()
                    }
                    .padding(.bottom, 15)
                    .padding(.horizontal, 25)
                    
                    ProfileTabView(selectedTab: $selectedTab)
                        .onChange(of: selectedTab) { oldValue, newValue in
                            if newValue == .hidden && !isHiddenUnlocked {
                                showingPinEntry = true
                            }
                        }
                    
                    TabView(selection: $selectedTab) {
                        ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, tab: .all, namespace: profileNamespace)
                            .tag(ProfileTab.all)
                        
                        ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, tab: .favorited, namespace: profileNamespace)
                            .tag(ProfileTab.favorited)
                        
                        ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, tab: .published, namespace: profileNamespace)
                            .tag(ProfileTab.published)
                        
                        Group {
                            if isHiddenUnlocked {
                                ProfileGridContainer(rootTabSelection: $mainTabSelection, selectedDraft: $selectedDraft, showNote: $showNote, tab: .hidden, namespace: profileNamespace)
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
            }
            .fullScreenCover(isPresented: $showingPinEntry) {
                PinEntryView(isUnlocked: $isHiddenUnlocked)
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
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(selectedDraft: $selectedDraft, showNote: $showNote)
                .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $showNote) {
                if let draft = selectedDraft {
                    FullNoteView(draft: draft, userViewModel: userViewModel)
                        .toolbar(.hidden, for: .tabBar)
                        .navigationTransition(.automatic)
                }
            }
        }
    }
    
    func toggleSettings() {
        if showSettings != true {
            showSettings = true
        }
    }
}
