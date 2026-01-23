import SwiftUI

struct ProfileGridContainer: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var rootTabSelection: ContentTabViewSelection
    let tab: ProfileTab
    
    var body: some View {
        Group {
            switch userViewModel.cardLoadingState {
            case .loading:
                ResponsiveGridView(items: (1...12).map { FakeItem(id: $0) }) { _ in
                    SkeletonCardView()
                }
            case .complete:
                let filteredData = getFilteredData()
                
                if filteredData.isEmpty {
                    emptyView
                } else {
                    ResponsiveGridView(items: filteredData) { draft in
                        CardView(draft: draft)
                    }
                }
            case .empty:
                emptyView
            case .error(let message):
                Text(message).font(.caption).foregroundColor(.red)
            }
        }
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

struct ResponsiveGridView<Content: View, T: Identifiable>: View {
    let items: [T]
    let content: (T) -> Content
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(items) { item in
                    content(item)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
    }
}

struct FakeItem: Identifiable {
    let id: Int
}
