import SwiftUI
import PhotosUI

@MainActor
struct ProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var selectedTab: ProfileTab = .all
    @State private var showNote: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isPhotoPickerPresented: Bool = false
    @State private var localProfileImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            VStack {
                HStack (spacing: 10) {
                    Text("My Valt")
                        .font(.custom("OpenSans-SemiBold", size: 24))
                    Spacer()
                    Button { showSettings = true } label: {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("BubbleColor"))
                            Image("settingsIcon")
                                .frame(width: 38, height: 38)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Profile section
                HStack {
                    AvatarView(
                        loadingState: userViewModel.userLoadingState,
                        profileImage: localProfileImage
                    )
                    .onTapGesture { isPhotoPickerPresented = true }
                    .photosPicker(
                        isPresented: $isPhotoPickerPresented,
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    )
                    .onChange(of: selectedItem) { _, newValue in
                        Task {
                            guard
                                let item = newValue,
                                let data = try? await item.loadTransferable(type: Data.self),
                                let uiImage = UIImage(data: data)
                            else { return }
                            await userViewModel.uploadProfilePicture(uiImage) // async
                        }
                    }
                    
                    UserInfoView(userViewModel: userViewModel)
                    
                    Spacer()
                }
                .padding(.leading, 20)
                
                ProfileTabView(selectedTab: $selectedTab)
                    .padding(.horizontal, 15)
                
                TabView(selection: $selectedTab) {
                    draftsGrid(for: .all)
                        .tag(ProfileTab.all)
                    
                    draftsGrid(for: .favorited)
                        .tag(ProfileTab.favorited)
                    
                    draftsGrid(for: .published)
                        .tag(ProfileTab.published)
                    
                    draftsGrid(for: .hidden)
                        .tag(ProfileTab.hidden)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onReceive(userViewModel.$profileImage) { newImage in
            localProfileImage = newImage
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    @ViewBuilder
    private func draftsGrid(for tab: ProfileTab) -> some View {
        let filteredData: [Draft] = {
            let allSorted = userViewModel.drafts.sorted { $0.timestamp > $1.timestamp }
            switch tab {
            case .all: return allSorted
            case .favorited: return allSorted.filter { $0.isFavorited }
            case .published: return allSorted.filter { $0.isPublished }
            case .hidden: return allSorted.filter { $0.isHidden }
            }
        }()

        switch userViewModel.cardLoadingState {
        case .loading:
            ResponsiveGridView(items: (1...12).map { FakeItem(id: $0) }) { _ in
                SkeletonCardView()
            }
        case .complete:
            ResponsiveGridView(items: filteredData) { draft in
                CardView(draft: draft)
            }
        case .empty:
            VStack {
                Image("noDrafts")
                    .resizable()
                    .frame(width: 200, height: 200)
            }
        case .error:
            Text("An error occurred :(")
                .font(.custom("OpenSans-Regular", size: 18))
        }
    }
}
