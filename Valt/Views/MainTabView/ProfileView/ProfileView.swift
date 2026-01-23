import SwiftUI
import PhotosUI

@MainActor
struct ProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var selectedFilter: Filter? = nil
    @State private var showFilterOptions: Bool = false
    @State private var showNote: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isPhotoPickerPresented: Bool = false
    @State private var localProfileImage: UIImage? = nil
    
    var filteredDrafts: [Draft] {
        guard let selectedFilter = selectedFilter else {
            return userViewModel.drafts.sorted { $0.timestamp > $1.timestamp }
        }
        switch selectedFilter {
        case .favorites: return userViewModel.drafts.filter { $0.isFavorited }
        case .hidden:    return userViewModel.drafts.filter { $0.isHidden }
        case .published: return userViewModel.drafts.filter { $0.isPublished }
        }
    }
    
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
                .padding(.leading, 30)
                
                // Archives Header
                HStack {
                    Text("Library")
                        .font(.custom("OpenSans-SemiBold", size: 19))
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 80, height: 30)
                            .cornerRadius(10)
                            .foregroundColor(Color("BubbleColor"))
                        Button { showFilterOptions.toggle() } label: {
                            HStack(spacing: 5) {
                                Text("Filter")
                                    .font(.custom("OpenSans-Regular", size: 15))
                                    .foregroundColor(Color("TextColor"))
                                Image("filterIcon")
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                    .popover(isPresented: $showFilterOptions) {
                        FilterOptionsView(selection: $selectedFilter)
                            .presentationCompactAdaptation(.popover)
                    }
                }
                
                draftsGrid
                    .animation(.easeInOut, value: userViewModel.cardLoadingState)
                
                Spacer()
            }
            .padding(.horizontal, 20)
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

    private var draftsGrid: some View {
        Group {
            switch userViewModel.cardLoadingState {
            case .loading:
                // Use 12 fake items to show 12 skeletons
                ResponsiveGridView(items: (1...12).map { FakeItem(id: $0) }) { _ in
                    SkeletonCardView()
                }
                
            case .complete:
                ResponsiveGridView(items: filteredDrafts) { draft in
                    CardView(draft: draft)
                }
                
            case .empty:
                ZStack {
                    Image("noDrafts")
                        .resizable()
                        .frame(width: 200, height: 200)
                }
            case .error:
                ZStack {
                    Text("An error occured :(")
                        .font(.custom("OpenSans-Regular", size: 18))
                }
                .padding(.vertical, 10)
            }
        }
    }
    
    struct FakeItem: Identifiable {
        let id: Int
    }
}
