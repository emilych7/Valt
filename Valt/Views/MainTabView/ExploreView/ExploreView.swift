import SwiftUI
import FirebaseAuth

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var isSearching: Bool = false
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            MainHeader(title: isSearching ? "Search" : "Explore Prompts")

            searchBarArea
                .padding(.horizontal, 25)
                .padding(.vertical, 10)

            if isSearching {
                SearchView(viewModel: ExploreViewModel())
                    .transition(.opacity)
            } else {
                PromptSuggestionView(viewModel: ExploreViewModel())
            }
        }
        .background(Color("AppBackgroundColor"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSearching)
    }

    private var searchBarArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TextFieldBackground"))
                .frame(height: 50)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("TextColor").opacity(0.50), lineWidth: 1))

            HStack(spacing: 8) {
                Image("searchIcon")
                    .resizable()
                    .frame(width: 15, height: 15)

                TextField("Search for a username", text: $viewModel.searchText)
                    .focused($isSearchFieldFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .font(.custom("OpenSans-Regular", size: 16))
                    .foregroundColor(Color("TextColor"))
                    .onChange(of: isSearchFieldFocused) { _, isFocused in
                        if isFocused { withAnimation { isSearching = true } }
                    }
                
                if isSearching {
                    Button("Cancel") {
                        withAnimation {
                            isSearching = false
                            isSearchFieldFocused = false
                            viewModel.searchText = ""
                        }
                    }
                    .font(.custom("OpenSans-SemiBold", size: 14))
                    .foregroundColor(Color("TextColor"))
                }
            }
            .padding(.horizontal, 15)
        }
    }
}
