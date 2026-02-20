import SwiftUI

struct ProfileGridContainer: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var rootTabSelection: ContentTabViewSelection
    @Binding var selectedDraft: Draft?
    @Binding var showNote: Bool
    let tab: ProfileTab
    var namespace: Namespace.ID
    
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
                                .matchedGeometryEffect(id: draft.id, in: namespace)
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
            case .all: return allSorted.filter { !$0.isHidden && !$0.isArchived }
            case .favorited: return allSorted.filter { $0.isFavorited && !$0.isHidden && !$0.isArchived }
            case .published: return allSorted.filter { $0.isPublished && !$0.isHidden && !$0.isArchived }
            case .hidden: return allSorted.filter { $0.isHidden && !$0.isArchived }
        }
    }
    
    @ViewBuilder
    private var emptyView: some View {
        VStack {
            Spacer()
            
            Text(emptyMessage)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .font(.custom("OpenSans-Regular", size: 14))
    }

    private var emptyMessage: String {
        switch tab {
        case .all: return "Nothing to see here..."
        case .favorited: return "No favorited drafts yet."
        case .published: return "No published drafts yet."
        case .hidden: return "No hidden drafts yet."
        }
    }
}

struct FakeItem: Identifiable {
    let id: Int
}
