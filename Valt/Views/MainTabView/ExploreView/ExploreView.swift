import SwiftUI

struct ExploreView: View {
    let placeholder: String = "Search for a username"
    @StateObject private var viewModel = ExploreViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MainHeader(title: "Explore")
                
                // Search
                ZStack {
                    TextField(placeholder, text: $viewModel.searchText)
                        .focused($isSearchFocused)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.5))
                        .padding(.horizontal, 15)
                        .frame(height: 50)
                        .background(Color("TextFieldBackground"))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .onChange(of: viewModel.searchText) {
                            viewModel.onSearchTextChanged()
                        }
                }
                .padding(.top, 5)
                .padding(.bottom, 15)
                .background(Color("AppBackgroundColor"))
                .overlay( Divider()
                    .frame(maxWidth: .infinity, maxHeight:1)
                    .background(Color("TextColor").opacity(0.2)), alignment: .bottom)
                VStack {
                // Results
                    if viewModel.isSearching && viewModel.userSuggestions.isEmpty {
                        ProgressView()
                            .padding()
                    } else {
                        List(viewModel.userSuggestions) { user in
                            Button {
                                viewModel.selectUser(user)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color("TextColor"))
                                    
                                    Text(user.username)
                                        .foregroundColor(Color("TextColor"))
                                        .font(.custom("OpenSans-Regular", size: 16))
                                    
                                    Spacer()
                                }
                            }
                            .listRowBackground(Color("AppBackgroundColor"))
                        }
                    }
                    
                    Spacer()
                }
                .background(Color("ValtRed"))
                
            }
            .background(
                ZStack {
                    Color("AppBackgroundColor")
                    Color("TextFieldBackground").opacity(0.7)
                }
                .ignoresSafeArea()
            )
        }
    }
}
