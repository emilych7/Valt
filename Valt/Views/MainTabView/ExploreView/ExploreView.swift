import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var tabManager: TabManager
    let placeholder: String = "Search for a username"
    @StateObject private var viewModel = ExploreViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    MainHeader(title: "Explore")
                    
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("TextColor"))
                            
                            TextField(placeholder, text: $viewModel.searchText)
                                .focused($isSearchFocused)
                                .font(.custom("OpenSans-Regular", size: 16))
                                .onChange(of: viewModel.searchText) { oldValue, newValue in
                                    if newValue.count > 15 { // limiting the search to 15 characters (that's the max character length of any username)
                                        viewModel.searchText = String(newValue.prefix(15))
                                    }
                                    viewModel.onSearchTextChanged()
                                }
                            
                            if !viewModel.searchText.isEmpty || isSearchFocused {
                                Button {
                                    isSearchFocused = false
                                    viewModel.searchText = ""
                                } label: {
                                    Image("cancelIcon")
                                        .resizable()
                                        .frame(width: 17, height: 17)
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 15)
                        .frame(height: 50)
                        .background(Color("TextFieldBackground"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .background(Color("AppBackgroundColor"))
                .overlay(
                    Rectangle()
                        .fill(Color("TextColor").opacity(0.2))
                        .frame(height: 1),
                    alignment: .bottom
                )
                
                // Content area
                ZStack {
                    if !isSearchFocused && viewModel.searchText.isEmpty {
                        exploreGridView
                            .transition(.opacity)
                    } else {
                        VStack {
                            if viewModel.isSearching && viewModel.userSuggestions.isEmpty {
                                ProgressView().padding(.top, 50)
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 0) {
                                        ForEach(viewModel.userSuggestions) { user in
                                            userSearchCell(user)
                                        }
                                    }
                                }
                                .scrollDismissesKeyboard(.interactively)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("TextFieldBackground").opacity(0.7))
                .onTapGesture {
                    isSearchFocused = false
                }
            }
            .background(Color("AppBackgroundColor"))
            .onChange(of: isSearchFocused) { _, focused in
                tabManager.setTabBarHidden(focused)
            }
            .navigationDestination(item: $viewModel.selectedUser) { user in
                // Text("Profile for \(user.username)")
                OtherUserView()
                    .environmentObject(viewModel)
                    .navigationBarBackButtonHidden(true)
            }
            // .animation(.snappy(duration: 0.25), value: isSearchFocused)
        }
    }
    
    private var exploreGridView: some View {
        ScrollView {
            VStack {
                Text("Find someone you know. Read their thoughts.")
                    .foregroundColor(Color("TextColor").opacity(0.7))
                    .font(.custom("OpenSans-Regular", size: 14))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 50)
        }
    }

    private func userSearchCell(_ user: OtherUser) -> some View {
        Button {
            viewModel.selectUser(user)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("TextColor"))
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.custom("OpenSans-SemiBold", size: 16))
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
