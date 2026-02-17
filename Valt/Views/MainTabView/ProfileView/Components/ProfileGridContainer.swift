import SwiftUI

struct ProfileGridContainer: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var rootTabSelection: ContentTabViewSelection
    @Binding var selectedDraft: Draft?
    @Binding var showNote: Bool
    let tab: ProfileTab
    
    var body: some View {
        Group {
            switch userViewModel.cardLoadingState {
            case .loading:
                VStack (alignment: .center){
                    ProgressView()
                        .controlSize(.regular)
                        .tint(Color("TextColor"))
                }
            case .complete:
                let filteredData = getFilteredData()
                
                if filteredData.isEmpty {
                    emptyView
                } else {
                    ResponsiveGridView(items: filteredData) { draft in
                        CardView(userViewModel: userViewModel, draft: draft, selectedDraft: $selectedDraft, showNote: $showNote)
                    }
                }
            case .empty:
                emptyView
            case .error(let message):
                Text(message).font(.caption).foregroundColor(.red)
            }
        }
        .overlay(
            Rectangle()
                .fill(Color("TextColor").opacity(0.2))
                .frame(width: 0.5)
            , alignment: .trailing
        )
    }
    
    private func getFilteredData() -> [Draft] {
        let allSorted = userViewModel.drafts.sorted { $0.timestamp > $1.timestamp }
        switch tab {
        case .all: return allSorted
        case .favorited: return allSorted.filter { $0.isFavorited }
        case .published: return allSorted.filter { $0.isPublished }
        case .hidden: return allSorted.filter { $0.isHidden }
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack {
            Spacer()
            if tab == .all {
                HStack(spacing: 4) {
                    Text("No drafts yet.")
                        .foregroundColor(Color("TextColor"))
                    Button {
                        withAnimation(.spring()) {
                            rootTabSelection = .home
                        }
                    } label: {
                        Text("Create your first one.")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
            } else {
                Text(emptyMessage)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .font(.custom("OpenSans-Regular", size: 14))
    }

    private var emptyMessage: String {
        switch tab {
        case .all: return "No drafts yet."
        case .favorited: return "No favorited drafts yet."
        case .published: return "No published drafts yet."
        case .hidden: return "No hidden drafts yet."
        }
    }
}

struct FakeItem: Identifiable {
    let id: Int
}
