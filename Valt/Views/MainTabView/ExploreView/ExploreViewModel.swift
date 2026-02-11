import Foundation
import FirebaseAuth

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var generatedPrompts: [String] = ["Come back when you have at least 3 notes..."]
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var userSuggestions: [OtherUser] = []
    @Published var selectedUser: OtherUser? = nil
    
    @Published var publishedDraftsForUser: [Draft] = []

    private let repository: DraftRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
    }

    func onSearchTextChanged() {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()
        
        if q.isEmpty {
            self.userSuggestions = []
            self.isSearching = false
            return
        }

        isSearching = true

        searchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            
            do {
                let usernames = try await repository.searchUsers(prefix: q, limit: 15)
                
                self.userSuggestions = usernames.map { name in
                    OtherUser(
                        id: name,
                        username: name,
                        profileImageUrl: nil,
                        publishedDrafts: []
                    )
                }
            } catch {
                self.userSuggestions = []
                print("Search error: \(error.localizedDescription)")
            }
            self.isSearching = false
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
    
    func loadPublishedDrafts(for username: String) async {
        do {
            let items = try await repository.fetchPublishedDrafts(forUsername: username)
            self.publishedDraftsForUser = items
        } catch {
            print("Error loading published drafts for \(username): \(error.localizedDescription)")
            self.publishedDraftsForUser = []
        }
    }
}
