import SwiftUI

struct ExploreView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @EnvironmentObject private var tabManager: TabManager
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @StateObject private var viewModel = ExploreViewModel()
    @FocusState private var isSearchFocused: Bool
    @State private var selectedPromptForDraft: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ExploreSearchBar(
                        searchText: $viewModel.searchText,
                        isFocused: $viewModel.isSearchFocused,
                        searchScope: $viewModel.searchScope,
                        placeholder: "Search",
                        onSearchChanged: {
                            viewModel.onSearchTextChanged()
                        },
                        onCancel: {
                            viewModel.resetSearch()
                        }
                    )
                    .padding(.bottom, 6)
                }
                .background(Color("AppBackgroundColor"))
                .overlay(
                    Rectangle()
                        .fill(Color("TextColor").opacity(0.08))
                        .frame(height: 1),
                    alignment: .bottom
                )
                
                ZStack {
                    if isSearchingActive {
                        searchResultsView
                            .transition(.opacity)
                    } else if viewModel.isNotesLoading && viewModel.filteredExploreNotes.isEmpty {
                        ExploreSkeletonGrid()
                            .transition(.opacity)
                    } else {
                        InstagramExploreGrid(
                            notes: viewModel.filteredExploreNotes,
                            promptSuggestions: viewModel.activePromptSuggestions,
                            onSelectNote: { note in
                                viewModel.selectedExploreNote = note
                            },
                            onAuthorTap: { author in
                                viewModel.selectUser(author)
                            },
                            onFavoriteToggle: { note in
                                viewModel.toggleFavorite(for: note)
                            },
                            onSelectPrompt: { prompt in
                                selectedPromptForDraft = prompt
                            },
                            onRefresh: {
                                await viewModel.refreshExploreNotes()
                            }
                        )
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.isNotesLoading)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("TextFieldBackground").opacity(0.45))
            }
            .background(Color("AppBackgroundColor").ignoresSafeArea())
            .onAppear {
                UIScrollView.appearance().bounces = true
                UIScrollView.appearance().alwaysBounceVertical = true
                viewModel.setup(tabManager)
                viewModel.integrateAIPrompts(homeViewModel.generatedPrompts)
            }
            .onChange(of: homeViewModel.generatedPrompts) { newPrompts in
                viewModel.integrateAIPrompts(newPrompts)
            }
            .navigationDestination(item: $viewModel.selectedUser) { user in
                OtherUserView()
                    .environmentObject(viewModel)
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedPromptForDraft != nil },
                set: { if !$0 { selectedPromptForDraft = nil } }
            )) {
                if let prompt = selectedPromptForDraft {
                    NewPromptedDraftView(selectedPrompt: prompt)
                        .environmentObject(userViewModel)
                        .environmentObject(homeViewModel)
                        .environmentObject(bannerManager)
                        .environmentObject(tabManager)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .sheet(item: $viewModel.selectedExploreNote) { note in
                ExploreNoteDetailSheet(
                    note: note,
                    onAuthorTap: { author in
                        viewModel.selectUser(author)
                    },
                    onFavoriteToggle: { note in
                        viewModel.toggleFavorite(for: note)
                    }
                )
                .environmentObject(bannerManager)
            }
            .animation(.snappy(duration: 0.25), value: viewModel.isSearchFocused)
        }
    }
    
    private var isSearchingActive: Bool {
        viewModel.isSearchFocused || !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            if viewModel.isSearching && viewModel.userSuggestions.isEmpty && viewModel.filteredExploreNotes.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                        .padding(.top, 50)
                    Text("Searching...")
                        .font(.custom("OpenSans-Regular", size: 13))
                        .foregroundColor(Color("TextColor").opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            } else if viewModel.userSuggestions.isEmpty && viewModel.filteredExploreNotes.isEmpty && !viewModel.searchText.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 38, weight: .light))
                        .foregroundColor(Color("TextColor").opacity(0.3))
                        .padding(.top, 60)
                    
                    Text("No results for \"\(viewModel.searchText)\"")
                        .font(.custom("OpenSans-SemiBold", size: 16))
                        .foregroundColor(Color("TextColor"))
                    
                    Text("Try searching for another username, note keyword, or topic.")
                        .font(.custom("OpenSans-Regular", size: 13))
                        .foregroundColor(Color("TextColor").opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        if (viewModel.searchScope == .all || viewModel.searchScope == .creators) && !viewModel.userSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CREATORS")
                                    .font(.custom("OpenSans-Bold", size: 11))
                                    .foregroundColor(Color("TextColor").opacity(0.55))
                                    .tracking(1)
                                    .padding(.horizontal, 22)
                                    .padding(.top, 12)
                                
                                ForEach(viewModel.userSuggestions) { user in
                                    userSearchCell(user)
                                }
                            }
                        }
                        
                        if (viewModel.searchScope == .all || viewModel.searchScope == .notes) && !viewModel.filteredExploreNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("MATCHING NOTES (\(viewModel.filteredExploreNotes.count))")
                                    .font(.custom("OpenSans-Bold", size: 11))
                                    .foregroundColor(Color("TextColor").opacity(0.55))
                                    .tracking(1)
                                    .padding(.horizontal, 22)
                                    .padding(.top, 14)
                                
                                ForEach(viewModel.filteredExploreNotes) { note in
                                    noteSearchResultCell(note)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func userSearchCell(_ user: OtherUser) -> some View {
        Button {
            viewModel.selectUser(user)
        } label: {
            HStack(spacing: 12) {
                if let url = URL(string: user.profileImageURL), !user.profileImageURL.isEmpty {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 38, height: 38)
                        .foregroundColor(Color("TextColor").opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.username)
                        .font(.custom("OpenSans-SemiBold", size: 15))
                        .foregroundColor(Color("TextColor"))
                    
                    Text("Valt Creator")
                        .font(.custom("OpenSans-Regular", size: 12))
                        .foregroundColor(Color("TextColor").opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("TextColor").opacity(0.3))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 22)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func noteSearchResultCell(_ note: ExploreNote) -> some View {
        Button {
            viewModel.selectedExploreNote = note
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if let url = URL(string: note.authorProfileImageURL), !note.authorProfileImageURL.isEmpty {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(Color("TextColor").opacity(0.4))
                                }
                            }
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(Color("TextColor").opacity(0.4))
                        }
                        
                        Text(note.authorUsername)
                            .font(.custom("OpenSans-SemiBold", size: 12))
                            .foregroundColor(Color("TextColor").opacity(0.7))
                        
                        Text("•")
                            .foregroundColor(Color("TextColor").opacity(0.3))
                        
                        Text(note.relativeTime)
                            .font(.custom("OpenSans-Regular", size: 11))
                            .foregroundColor(Color("TextColor").opacity(0.5))
                        
                        Spacer()
                        
                        if note.isPrompted {
                            Image("promptsIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                        }
                    }
                    
                    Text(note.title)
                        .font(.custom("OpenSans-Bold", size: 14))
                        .foregroundColor(Color("TextColor"))
                        .lineLimit(1)
                    
                    Text(note.content)
                        .font(.custom("OpenSans-Regular", size: 12))
                        .foregroundColor(Color("TextColor").opacity(0.75))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("TextColor").opacity(0.3))
                    .padding(.top, 14)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("CardColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color("TextColor").opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExploreView(homeViewModel: HomeViewModel(userViewModel: UserViewModel.preview))
        .environmentObject(TabManager())
        .environmentObject(BannerManager())
        .environmentObject(UserViewModel.preview)
}

