import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    @Binding var showSettingsOverlayBinding: Bool
    
    // Filter selection state
    @State private var selectedFilter: Filter? = nil
    @State private var showFilterOptions: Bool = false
    
    // Show full note state
    @State private var showNote: Bool = false
    
    // Profile picture picker state
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var filteredDrafts: [Draft] {
        guard let selectedFilter = selectedFilter else {
            return viewModel.drafts
        }

        switch selectedFilter {
        case .mostRecent:
            return viewModel.drafts.sorted { $0.timestamp > $1.timestamp }
        case .favorites:
            return viewModel.drafts.filter { $0.isFavorited }
        case .hidden:
            return viewModel.drafts.filter { $0.isHidden }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack (spacing: 15) {
                        GlowingView()
                        Text("Welcome, username")
                            .font(.custom("OpenSans-Regular", size: 24))
                    }
                    Spacer()
                    Button(action: {
                        showSettingsOverlayBinding.toggle()
                    }) {
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
                .padding(.leading, 25)
                .padding(.top, 20)
                .padding(.trailing, 25)
                
                // Profile Section
                HStack {
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if let profileImage = viewModel.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 115, height: 115)
                                    .clipShape(Ellipse())
                            } else {
                                Ellipse()
                                    .frame(width: 115, height: 115)
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
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            if let item = newValue,
                               let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                viewModel.uploadProfilePicture(uiImage)
                            }
                        }
                    }

                    
                    VStack (alignment: .leading, spacing: 5) {
                        Text("@username") // Replace with actual username if available
                            .font(.custom("OpenSans-SemiBold", size: 23))
                        
                        Text("\(viewModel.draftCount) notes")
                            .font(.custom("OpenSans-Regular", size: 16))
                        
                        Text("# published") // Replace with published count if available
                            .font(.custom("OpenSans-Regular", size: 16))
                    }
                    .padding(.horizontal, 5)
                    .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                }
                .padding(.leading, 35)
                .padding(.trailing, 20)
                
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
                        Button(action: {
                            showFilterOptions.toggle()
                        }
                        ) {
                            HStack (spacing: 5) {
                                Text("Filter")
                                    .font(.custom("OpenSans-Regular", size: 14))
                                    .foregroundColor(Color("TextColor"))
                                Image("filterIcon")
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                    .popover(isPresented: $showFilterOptions, content: {
                        FilterOptionsView(selection: $selectedFilter)
                            .presentationCompactAdaptation(.popover)
                    })
                }
                .padding(.top, 10)
                .padding(.horizontal, 25)
                
                // Drafts Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(filteredDrafts) { draft in
                            CardView(id: draft.id, title: draft.title, content: draft.content, timestamp: draft.timestamp)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 10)
                }
                .scrollIndicators(.hidden)
                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            viewModel.loadDrafts()
            viewModel.fetchDraftCount()
            viewModel.fetchProfilePicture()
        }
    }
}

#Preview {
    ProfileView(showSettingsOverlayBinding: .constant(false))
}
