import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var isSearching: Bool = false
    @FocusState private var isSearchFieldFocused: Bool
    
    enum ExploreTab {
        case suggestions, search
    }
    @State private var activeTab: ExploreTab = .suggestions

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
            // Disable swiping if the keyboard/cancel button should trigger it
            .gesture(isSearchFieldFocused ? DragGesture() : nil)
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
            .background(Color("TextFieldBackground"))
            .cornerRadius(12)

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
