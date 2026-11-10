import Foundation
import SwiftUI

enum ExploreSearchScope: String, CaseIterable, Identifiable {
    case all = "All"
    case notes = "Notes"
    case creators = "Creators"
    
    var id: String { rawValue }
}

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var isLoading: Bool = false
    @Published var isNotesLoading: Bool = false
    @Published var userSuggestions: [OtherUser] = []
    @Published var selectedUser: OtherUser? = nil
    @Published var publishedDraftsForUser: [Draft] = []
    @Published var generatedPrompts: [String] = ["Come back when you have at least 3 notes..."]
    
    @Published var exploreNotes: [ExploreNote] = []
    @Published var selectedExploreNote: ExploreNote? = nil
    @Published var searchScope: ExploreSearchScope = .all
    @Published var activePromptSuggestions: [String] = []
    private var externalAIPrompts: [String] = []
    
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
        self.exploreNotes = ExploreNote.sampleNotes
        self.refreshPromptSuggestions()
        
        Task {
            await loadExploreNotes()
        }
    }
    
    func setup(_ manager: TabManager) {
        self.tabManager = manager
    }

    var filteredExploreNotes: [ExploreNote] {
        var notes = exploreNotes
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty && (searchScope == .all || searchScope == .notes) {
            notes = notes.filter { note in
                note.title.lowercased().contains(query) ||
                note.content.lowercased().contains(query) ||
                note.authorUsername.lowercased().contains(query) ||
                (note.prompt?.lowercased().contains(query) ?? false)
            }
        }
        
        return notes
    }

    func loadExploreNotes() async {
        isNotesLoading = true
        defer { isNotesLoading = false }
        do {
            let fetched = try await repository.fetchExploreNotes()
            if !fetched.isEmpty {
                self.exploreNotes = fetched
            } else {
                self.exploreNotes = ExploreNote.sampleNotes
            }
        } catch {
            self.exploreNotes = ExploreNote.sampleNotes
        }
    }
    
    func refreshExploreNotes() async {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        await loadExploreNotes()
        withAnimation(.snappy(duration: 0.25)) {
            refreshPromptSuggestions()
        }
    }
    
    func integrateAIPrompts(_ prompts: [String]) {
        let valid = prompts.filter { !$0.isEmpty && !$0.contains("Come back when you have") }
        guard valid != self.externalAIPrompts else { return }
        self.externalAIPrompts = valid
        refreshPromptSuggestions()
    }
    
    func refreshPromptSuggestions() {
        var pool = Self.curatedPrompts.shuffled()
        if !externalAIPrompts.isEmpty {
            let aiShuffled = externalAIPrompts.shuffled()
            pool = aiShuffled + pool
        }
        self.activePromptSuggestions = pool
    }
    
    func toggleFavorite(for note: ExploreNote) {
        guard let index = exploreNotes.firstIndex(where: { $0.id == note.id }) else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        exploreNotes[index].isFavorited.toggle()
        if exploreNotes[index].isFavorited {
            exploreNotes[index].favoritesCount += 1
        } else {
            exploreNotes[index].favoritesCount = max(0, exploreNotes[index].favoritesCount - 1)
        }
        
        if selectedExploreNote?.id == note.id {
            selectedExploreNote = exploreNotes[index]
        }
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
            try? await Task.sleep(nanoseconds: 220_000_000)
            guard !Task.isCancelled else { return }
            
            do {
                let users = try await repository.searchUsers(prefix: query, limit: 15)
                
                let suggestions = await withTaskGroup(of: (Int, OtherUser).self) { group in
                    for (index, var user) in users.enumerated() {
                        group.addTask {
                            let url = await self.repository.getProfileImageURL(for: user.id)
                            user.profileImageURL = url
                            return (index, user)
                        }
                    }
                    
                    var indexedResults: [(Int, OtherUser)] = []
                    for await item in group {
                        indexedResults.append(item)
                    }
                    return indexedResults.sorted { $0.0 < $1.0 }.map { $0.1 }
                }
                
                var localMatches: [OtherUser] = []
                for note in self.exploreNotes {
                    let usernameWithoutAt = note.authorUsername.replacingOccurrences(of: "@", with: "")
                    if usernameWithoutAt.lowercased().hasPrefix(query.lowercased()) &&
                       !suggestions.contains(where: { $0.username.lowercased() == usernameWithoutAt.lowercased() }) &&
                       !localMatches.contains(where: { $0.username.lowercased() == usernameWithoutAt.lowercased() }) {
                        localMatches.append(note.asOtherUser)
                    }
                }
                
                if !Task.isCancelled {
                    self.userSuggestions = suggestions + localMatches
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
        self.publishedDraftsForUser = user.publishedDrafts
        self.isLoading = true
        
        Task {
            await loadPublishedDrafts(for: user.username)
            self.isLoading = false
        }
    }

    private func loadPublishedDrafts(for username: String) async {
        let cleanUsername = username.replacingOccurrences(of: "@", with: "")
        do {
            let items = try await repository.fetchPublishedDrafts(forUsername: cleanUsername)
            if !items.isEmpty {
                self.publishedDraftsForUser = items
            } else if let selected = self.selectedUser, !selected.publishedDrafts.isEmpty {
                self.publishedDraftsForUser = selected.publishedDrafts
            } else {
                let authorNotes = exploreNotes.filter {
                    $0.authorUsername.replacingOccurrences(of: "@", with: "").lowercased() == cleanUsername.lowercased()
                }.map { $0.asDraft }
                self.publishedDraftsForUser = authorNotes
            }
        } catch {
            if let selected = self.selectedUser, !selected.publishedDrafts.isEmpty {
                self.publishedDraftsForUser = selected.publishedDrafts
            } else {
                self.publishedDraftsForUser = []
            }
        }
    }

    private func handleFocusChange(_ focused: Bool) {
        Task {
            tabManager?.setTabBarHidden(focused)
        }
    }

    func resetSearch() {
        self.userSuggestions = []
        self.isSearching = false
    }
    
    static let curatedPrompts: [String] = [
        "What brought you unexpected peace today?",
        "What is something non-essential you recently stopped doing to protect your focus?",
        "Write about an opinion you've changed your mind about over the years.",
        "What is a quiet habit that has kept you going through self-doubt?",
        "Describe a micro-moment from this week that you want to remember.",
        "What book or sentence altered the way you make daily decisions?",
        "What is a piece of advice you often give but struggle to follow yourself?",
        "What made you feel truly alive in the last forty-eight hours?",
        "Who in your life makes you feel understood without explaining yourself?",
        "What is a promise you made to yourself that you are still keeping?",
        "Describe a place where your thoughts automatically slow down.",
        "What truth did you recently accept that was hard to swallow?",
        "If you could tell your younger self one thing about failure, what would it be?",
        "What is an unanswered question you find yourself coming back to?",
        "What small ritual brings rhythm to an otherwise chaotic day?",
        "Write about something you forgave someone for without them asking.",
        "What emotion do you tend to suppress the most, and why?",
        "What does genuine rest look like for you when sleep isn't enough?",
        "What is something you loved doing as a child that you rarely do now?",
        "How do you know when a decision is coming from intuition versus fear?",
        "What is a conversation you need to have, but have been postponing?",
        "What boundary did you set that made your life noticeably better?",
        "Write about a stranger who left an unexpected imprint on your memory.",
        "What is something you are proud of that nobody else knows about?",
        "What has silence taught you when words fell short?",
        "What do you need to let go of before you can move forward?",
        "How has your definition of success shifted over the past year?",
        "Describe a moment when you felt proud of how you handled yourself.",
        "What is a belief you held strongly that no longer serves who you are?",
        "What is the kindest thing someone did for you during a dark season?",
        "What would you do today if you weren't concerned with anyone's approval?",
        "What is a memory that always brings a gentle smile to your face?",
        "How do you recharge when your social battery reaches zero?",
        "What does home feel like when it isn't a physical place?",
        "What is a creative project or dream you haven't spoken aloud yet?",
        "What part of your personality has softened with time?",
        "What is something you wish people understood about your quiet moments?",
        "What was a turning point in your life that didn't feel significant until later?",
        "What are you holding onto that feels heavier than it needs to be?",
        "Describe the atmosphere of your ideal morning from start to finish.",
        "What is something ordinary that you find extraordinary?",
        "What does patience feel like in your body when you are waiting for an answer?",
        "Who has been an anchor in your life, even from a distance?",
        "What is a lesson about love or friendship you had to learn the hard way?",
        "If today was your last ordinary day, what would you pay attention to?",
        "What is a fear you've outgrown without realizing it?",
        "What is something you are curious about right now?",
        "How do you know you are making progress when results are invisible?"
    ]
}
