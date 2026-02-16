import SwiftUI

struct OtherUserView: View {
    @EnvironmentObject private var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            MainHeader(title: viewModel.selectedUser?.username ?? "User", image: "bookmarkIcon-Unselected")
            
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
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.publishedDraftsForUser) { draft in
                                draftCell(draft)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("TextFieldBackground").opacity(0.7))
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
    }
    
    private func draftCell(_ draft: Draft) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(draft.content) 
                .font(.custom("OpenSans-Regular", size: 14))
                .foregroundColor(Color("TextColor").opacity(0.8))
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppBackgroundColor").opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}
