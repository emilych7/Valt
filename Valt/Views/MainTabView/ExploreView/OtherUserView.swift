import SwiftUI

struct OtherUserView: View {
    @EnvironmentObject private var viewModel: ExploreViewModel
    @State private var isBookmarked = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            OtherUserHeader(username: viewModel.selectedUser?.username ?? "User", image: isBookmarked ? "bookmarkIcon-Selected" :"bookmarkIcon-Unselected", action: toggleBookmark)
            
            ZStack {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .padding(.top, 50)
                        Spacer()
                    }
                } else if viewModel.publishedDraftsForUser.isEmpty {
                    VStack {
                        Text("No published drafts yet.")
                            .font(.custom("OpenSans-Regular", size: 14))
                            .foregroundColor(Color("TextColor"))
                            .padding(.top, 50)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        ResponsiveGridView(items: viewModel.publishedDraftsForUser) { draft in
                            OtherUserCardView(draft: draft)
                        }
                    }
                }
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("TextFieldBackground").opacity(0.7))
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
    }
    
    func toggleBookmark() {
        self.isBookmarked = !self.isBookmarked
    }
}
