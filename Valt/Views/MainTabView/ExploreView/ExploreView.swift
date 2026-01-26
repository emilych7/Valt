import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var viewModel: ExploreViewModel
    
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isSearching: Bool = false
    @State private var activeTab: ExploreTab = .suggestions

    enum ExploreTab {
        case suggestions, search
    }
    
    init(userViewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: ExploreViewModel(userViewModel: userViewModel))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            MainHeader(title: activeTab == .search ? "Search" : "Explore Prompts")

            searchBarArea
                .padding(.horizontal, 25)
                .padding(.vertical, 10)

            // Paged TabView
            TabView(selection: $activeTab) {
                PromptSuggestionView(viewModel: viewModel)
                    .tag(ExploreTab.suggestions)
                
                SearchView(viewModel: viewModel)
                    .tag(ExploreTab.search)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .highPriorityGesture(DragGesture())
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .onChange(of: activeTab) { _, newValue in
            if newValue == .suggestions {
                isSearchFieldFocused = false
                isSearching = false
            }
        }
    }

    private var searchBarArea: some View {
        HStack {
            HStack {
                Image("searchIcon")
                    .resizable()
                    .frame(width: 15, height: 15)

                TextField("Search for a username", text: $viewModel.searchText)
                    .focused($isSearchFieldFocused)
                    .onChange(of: isSearchFieldFocused) { _, isFocused in
                        if isFocused {
                            withAnimation(.spring()) { activeTab = .search }
                        }
                    }
            }
            .padding(.horizontal, 15)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("TextFieldBackground"))
                    .stroke(Color("TextColor").opacity(0.20), lineWidth: 1)
            )

            if activeTab == .search {
                Button("Cancel") {
                    withAnimation(.spring()) {
                        activeTab = .suggestions
                        isSearchFieldFocused = false
                        viewModel.searchText = ""
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}
