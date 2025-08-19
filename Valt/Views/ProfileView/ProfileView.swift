import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Binding var showSettingsOverlayBinding: Bool
    
    @State private var selectedFilter: Filter? = nil
    @State private var showFilterOptions: Bool = false
    @State private var showNote: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil

    // Mirror actor-isolated property
    @State private var localProfileImage: UIImage? = nil
    
    var filteredDrafts: [Draft] {
        guard let selectedFilter = selectedFilter else {
            return userViewModel.drafts.sorted { $0.timestamp > $1.timestamp }
        }
        switch selectedFilter {
        case .favorites:
            return userViewModel.drafts.filter { $0.isFavorited }
        case .hidden:
            return userViewModel.drafts.filter { $0.isHidden }
        case .published:
            // return userViewModel.drafts.sorted { $0.timestamp > $1.timestamp }
            return userViewModel.drafts.filter { $0.isPublished }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack (spacing: 10) {
                    GlowingView()
                        .frame(width: 20, height: 20)
                    
                    Text("My Valt")
                        .font(.custom("OpenSans-SemiBold", size: 24))
                    Spacer()
                    Button { showSettingsOverlayBinding.toggle() } label: {
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
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                // Profile section
                HStack {
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if let profileImage = localProfileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 105, height: 105)
                                    .clipShape(Ellipse())
                            } else {
                                Ellipse()
                                    .frame(width: 105, height: 105)
                                    .foregroundColor(Color("BubbleColor"))
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 24))
                                    )
                            }
                        }
                    }
                    .frame(width: 115, height: 115)
                    .onChange(of: selectedItem) { _, newValue in
                        Task {
                            if let item = newValue,
                               let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                userViewModel.uploadProfilePicture(uiImage)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(userViewModel.username)")
                            .font(.custom("OpenSans-SemiBold", size: 23))
                        
                        Text("\(userViewModel.draftCount) drafts")
                            .font(.custom("OpenSans-Regular", size: 16))
                        
                        Text("\(userViewModel.publishedDraftCount) published")
                            .font(.custom("OpenSans-Regular", size: 16))
                    }
                    .padding(.horizontal, 5)
                    .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                .padding(.horizontal, 35)
                
                // Archives Header
                HStack {
                    Text("Archives")
                        .font(.custom("OpenSans-SemiBold", size: 18))
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
                                    .font(.custom("OpenSans-Regular", size: 14))
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
                .padding(.top, 5)
                .padding(.horizontal, 25)
                
                switch userViewModel.loadingState {
                case .loading:
                    CardLoadingView()
                case .empty:
                    ZStack {
                        Image("noDrafts")
                            .resizable()
                            .frame(width: 220, height: 220)
                            .padding()
                    }
                    .padding(.vertical, 10)
                    
                case .error:
                    ZStack {
                        Text("An error occured :(")
                            .font(.custom("OpenSans-Regular", size: 18))
                    }
                    .padding(.vertical, 10)
                    
                case .complete:
                    /*
                    if userViewModel.draftCount != 0 {
                    */
                    // Drafts Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(filteredDrafts) { draft in
                                CardView(draftID: draft.id)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                    }
                    .scrollIndicators(.hidden)
                    
                    Spacer()
                    /*
                    }
                    else {
                        ZStack {
                            Image("noDrafts")
                                .resizable()
                                .frame(width: 220, height: 220)
                                .padding()
                        }
                        .padding(.vertical, 10)
                    }
                */
                }
                
                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Sync actor-isolated property to local @State
        .onReceive(userViewModel.$profileImage) { newImage in
            localProfileImage = newImage
        }
    }
}
