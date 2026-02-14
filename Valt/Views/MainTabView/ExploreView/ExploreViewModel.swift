import Foundation
import FirebaseAuth

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var isLoading: Bool = false
    @Published var userSuggestions: [OtherUser] = []
    @Published var selectedUser: OtherUser? = nil
    @Published var publishedDraftsForUser: [Draft] = []
    @Published var generatedPrompts: [String] = ["Come back when you have at least 3 notes..."]

    private let repository: DraftRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
    }
    
    // Triggered by .onChange(of: searchText) in the ExploreView
    func onSearchTextChanged() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        searchTask?.cancel()
        
        if query.isEmpty {
            resetSearch()
            return
        }

        isSearching = true

        searchTask = Task {
            // Waits for user to stop typing
            try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s
            guard !Task.isCancelled else { return }
            
            do {
                let usernames = try await repository.searchUsers(prefix: query, limit: 15)
                
                let suggestions = usernames.map { name in
                    OtherUser(id: name, username: name, profileImageUrl: nil, publishedDrafts: [])
                }
                
                if !Task.isCancelled {
                    self.userSuggestions = suggestions
                    self.isSearching = false
                }
            } catch {
                if !Task.isCancelled {
                    self.userSuggestions = []
                    self.isSearching = false
                }
            }
        }
    }

    func selectUser(_ user: OtherUser) {
        self.selectedUser = user
        self.isLoading = true
        
        Task {
            await loadPublishedDrafts(for: user.username)
            self.isLoading = false
        }
    }
    
    private func loadPublishedDrafts(for username: String) async {
        do {
            let items = try await repository.fetchPublishedDrafts(forUsername: username)
            self.publishedDraftsForUser = items
        } catch {
            print("Error loading drafts: \(error.localizedDescription)")
            self.publishedDraftsForUser = []
        }
    }

    private func resetSearch() {
        self.userSuggestions = []
        self.isSearching = false
    }
}
