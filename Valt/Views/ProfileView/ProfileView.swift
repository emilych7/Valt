import SwiftUI
import PhotosUI
import UIKit

extension UIImage {
    func resized(to newSize: CGSize, quality: CGFloat = 0.8) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSettingsOverlayBinding: Bool
    @State private var selectedFilter: Filter? = nil
    @State private var showFilterOptions: Bool = false
    @State private var showNote: Bool = false
    
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
    
    // 3-column grid layout
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)

    var body: some View {
        ZStack {
            VStack {
                // MARK: Header
                HStack {
                    HStack(spacing: 15) {
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
                
                // MARK: Profile Info
                HStack {
                    Ellipse()
                        .frame(width: 115, height: 115)
                        .foregroundColor(Color("BubbleColor"))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("@username") // TODO: Add username
                            .font(.custom("OpenSans-SemiBold", size: 23))
                        
                        Text("\(viewModel.draftCount) notes") // TODO: Add total note count
                            .font(.custom("OpenSans-Regular", size: 16))
                        
                        Text("# published") // TODO: Add published count
                            .font(.custom("OpenSans-Regular", size: 16))
                    }
                    .padding(.horizontal, 5)
                    .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                .padding(.leading, 35)
                .padding(.trailing, 20)
                
                // MARK: Archives Header
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
                        }) {
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
                .padding(.top, 10)
                .padding(.horizontal, 25)
                
                // MARK: Draft Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredDrafts) { draft in
                            CardView(
                                title: draft.title,
                                content: draft.content,
                                timestamp: draft.timestamp
                            )
                            .frame(
                                maxWidth: (UIScreen.main.bounds.width - 60) / 3
                            ) // 3 columns with spacing
                        }
                    }
                    .padding(.horizontal, 20)
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
        }
    }
}

#Preview {
    ProfileView(showSettingsOverlayBinding: .constant(false))
}
