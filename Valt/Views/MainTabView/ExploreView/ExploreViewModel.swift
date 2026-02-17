import Foundation
import FirebaseAuth
import FirebaseStorage

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var isLoading: Bool = false
    @Published var userSuggestions: [OtherUser] = []
    @Published var selectedUser: OtherUser? = nil
    @Published var publishedDraftsForUser: [Draft] = []
    @Published var generatedPrompts: [String] = ["Come back when you have at least 3 notes..."]
    
    @Published var isSearchFocused: Bool = false {
        didSet {
            handleFocusChange(isSearchFocused)
        }
    }

    private let repository: DraftRepositoryProtocol
    private var tabManager: TabManager?
    private var searchTask: Task<Void, Never>?

    init(repository: DraftRepositoryProtocol = DraftRepository(), tabManager: TabManager? = nil) {
        self.repository = repository
        self.tabManager = tabManager
    }
    
    func setup(_ manager: TabManager) {
        self.tabManager = manager
    }

    func onSearchTextChanged() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()
        
        if query.isEmpty {
            resetSearch()
            return
        }

        isSearching = true

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000) // Debounce
            guard !Task.isCancelled else { return }
            
            do {
                let users = try await repository.searchUsers(prefix: query, limit: 15)
                
                // Grabs Storage URLs in parallel
                let suggestions = await withTaskGroup(of: OtherUser.self) { group in
                    for var user in users {
                        group.addTask {
                            let url = await self.repository.getProfileImageURL(for: user.id)
                            user.profileImageURL = url
                            return user
                        }
                    }
                    
                    var results: [OtherUser] = []
                    for await updatedUser in group {
                        results.append(updatedUser)
                    }
                    return results
                }
                
                if !Task.isCancelled {
                    self.userSuggestions = suggestions
                    self.isSearching = false
                }
            } catch {
                self.isSearching = false
                print("Search error: \(error.localizedDescription)")
            }
        }
    }

    func selectUser(_ user: OtherUser) {
        self.selectedUser = user
        self.publishedDraftsForUser = []
        self.isLoading = true
        
        Task {
            await loadPublishedDrafts(for: user.username)
            self.isLoading = false
        }
    }

    private func fetchProfileURL(for userID: String) async -> String {
        let storageRef = Storage.storage().reference().child("profilePictures/\(userID).jpg")
        do {
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            return ""
        }
    }
    
    private func loadPublishedDrafts(for username: String) async {
        do {
            let items = try await repository.fetchPublishedDrafts(forUsername: username)
            self.publishedDraftsForUser = items
        } catch {
            self.publishedDraftsForUser = []
        }
    }

    private func handleFocusChange(_ focused: Bool) {
        Task {
            tabManager?.setTabBarHidden(focused)
        }
    }

    private func resetSearch() {
        self.userSuggestions = []
        self.isSearching = false
    }
}
