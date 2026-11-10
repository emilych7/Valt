import SwiftUI

struct OtherUserView: View {
    @EnvironmentObject private var viewModel: ExploreViewModel
    @State private var isBookmarked = false
    @State private var selectedDraft: Draft? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            OtherUserHeader(
                username: viewModel.selectedUser?.username ?? "User",
                image: isBookmarked ? "bookmarkIcon-Selected" : "bookmarkIcon-Unselected",
                action: toggleBookmark
            )
            
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
                            OtherUserCardView(draft: draft) {
                                selectedDraft = draft
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("TextFieldBackground").opacity(0.7))
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .sheet(item: $selectedDraft) { draft in
            let note = ExploreNote(
                id: draft.id,
                title: draft.title,
                content: draft.content,
                authorUsername: viewModel.selectedUser?.username ?? "@user",
                authorID: draft.userID,
                authorProfileImageURL: viewModel.selectedUser?.profileImageURL ?? "",
                timestamp: draft.timestamp,
                prompt: draft.prompt,
                isPrompted: draft.isPrompted,
                category: draft.isPrompted ? "Prompts" : "Reflections",
                favoritesCount: 0,
                isFavorited: draft.isFavorited,
                layoutSpan: .standard
            )
            ExploreNoteDetailSheet(
                note: note,
                onAuthorTap: { _ in },
                onFavoriteToggle: { _ in }
            )
        }
    }
    
    func toggleBookmark() {
        self.isBookmarked.toggle()
    }
}
