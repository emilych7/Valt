import Foundation
import FirebaseAuth

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var generatedPrompts: [String] = []
    @Published var isLoading: Bool = false
    @Published var showPrompts: Bool = false
    @Published var isPromptSelected: Bool = false

    // Search state
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var usernameSuggestions: [String] = []
    @Published var selectedUsername: String? = nil
    @Published var publishedDraftsForUser: [Draft] = []
    
    @Published var isEditing = false
    @Published var isFavorited = false
    @Published var prompt: String? = nil
    @Published var draftText = ""
    
    private let userViewModel: UserViewModel

    private let repository: DraftRepositoryProtocol
    private var searchTask: Task<Void, Never>? // for debouncing

    init(userViewModel: UserViewModel, repository: DraftRepositoryProtocol = DraftRepository()) {
        self.userViewModel = userViewModel
        self.repository = repository
    }

    // Username search (debounced)
    func onSearchTextChanged() {
            let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            searchTask?.cancel()
            isSearching = true

            searchTask = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(nanoseconds: 250_000_000) // ~250ms debounce
                guard !Task.isCancelled else { return }
                
                if q.isEmpty {
                    self.usernameSuggestions = []
                    self.isSearching = false
                    return
                }

                // Searching, update the UI state
                self.isSearching = true
                do {
                    let results = try await repository.searchUsernames(prefix: q, limit: 15)
                    self.usernameSuggestions = results
                } catch {
                    self.usernameSuggestions = []
                    print("Search error:", error.localizedDescription)
                }
                self.isSearching = false
            }
        }

    // Load published drafts for username selected
    func loadPublishedDrafts(for username: String) {
        selectedUsername = username
        isLoading = true
        Task {
            do {
                let drafts = try await repository.fetchPublishedDrafts(forUsername: username)
                self.publishedDraftsForUser = drafts
            } catch {
                self.publishedDraftsForUser = []
                print("Error loading published drafts:", error.localizedDescription)
            }
            self.isLoading = false
        }
    }

    func generatePromptFromOwnDrafts(with drafts: [Draft]) {
        print("Generating prompts with \(drafts.count) drafts...")
        isLoading = true

        guard drafts.count >= 3 else {
            self.generatedPrompts = ["Create at least three drafts to get a personalized prompt."]
            self.isLoading = false
            return
        }
        self.generatePrompt(from: drafts)
    }

    // Generate prompt from selected username’s published drafts
    func generatePromptFromPublishedDraftsForSelectedUser() {
        guard !publishedDraftsForUser.isEmpty else {
            generatedPrompts = ["No published drafts found for that user."]
            return
        }
        generatePrompt(from: publishedDraftsForUser)
    }

    // Prompt generator
    private func generatePrompt(from drafts: [Draft]) {
        let draftContext = drafts.map { d in
            "Title: \(d.title)\nContent: \(d.content)"
        }.joined(separator: "\n\n---\n\n")

        let metaPrompt = """
        Analyze the provided writing drafts and generate exactly 5 unique writing prompts.
        
        **Your task is to:**
            1.  **Generate Exactly 5 Unique and Creative Writing Prompts:** You must return a list of five distinct prompts. Do not return more or less than five.
            2.  **Follow Prompt Guidelines:** Each of the 5 prompts must adhere to the following rules:
                * **Format:** It must be a single question.
                * **Length:** It must be between 10-15 words. 
                * **Perspective:** It should be framed to elicit a first-person response, like a personal narrative or diary entry.
                * **Tone:** The question should sound like it's coming from a bestfriend seeking a psychological perspective. It should be easy to understand for an 18-24 year old demographic. The user should feel like the question is personalized for them, because the point of the questions are to help them dig deeper into the thoughts contained in the drafts.
                * **Goal:** Inspire the user to expand on themes from their drafts and reveal more about their thoughts and feelings. Avoid generic questions. The new prompt should also be framed as a question that gets them to respond in the first person like a personal narrative or diary entry. The new prompt should inspire the reader to want to expand on the strongest themes and deepest content from the drafts.
            3.  **Output Format:** Your response MUST be a single JSON object. This object must have a single key named "prompts", whose value is an array of the 5 generated prompt strings.

            **Example JSON Output:**
            {
              "prompts": [
                "What’s the most recent time you felt unconditional love for someone?",
                "What dream reoccurs for you?",
                "How would you describe the last summer to yourself in 10 years? ",
                "Describe your morning routine.",
                "List everyone who has done you right.",
                "How do you get yourself together after crashing out?"
              ]
            }

            **User's Drafts for Context:**
            ---
            \(draftContext)
            ---
        """

        let initialMessage = PromptMessage(sender: .user, content: metaPrompt)

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let jsonString = try await self.callChatGPTAPI(history: [initialMessage])
                // Convert the string to Data for the decoder
                guard let jsonData = jsonString.data(using: .utf8) else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"])
                }

                // Define the Codable struct inside the function or outside
                struct PromptResponse: Decodable {
                    let prompts: [String]
                }

                // Decode the JSON data directly into the Swift object
                let response = try JSONDecoder().decode(PromptResponse.self, from: jsonData)
                print("response")
                print("count: \(response.prompts.count)")
                print(response.prompts)
                
                self.generatedPrompts = response.prompts
                self.isLoading = false
            } catch {
                print("Error calling ChatGPT API:", error.localizedDescription)
                self.generatedPrompts = ["Failed to generate prompt. Error: \(error.localizedDescription)"]
                self.isLoading = false
            }
        }
    }

    // OPENAI
    func callChatGPTAPI(history: [PromptMessage]) async throws -> String {
            let urlString = "https://api.openai.com/v1/chat/completions"
            guard let url = URL(string: urlString) else {
                throw NSError(domain: "ChatAppError", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid OpenAI API URL"])
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let apiKey = Constants.OPENAI_API_KEY
            
            guard !apiKey.isEmpty else {
                throw NSError(domain: "ChatAppError", code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "Missing OpenAI API key. Check Constants.swift"])
            }
            
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let openAIMessages: [[String: String]] = history.map { message in
                let role = (message.sender == .user) ? "user" : "assistant"
                return ["role": role, "content": message.content]
            }

            let requestBody: [String: Any] = [
                "model": "gpt-4o",
                "messages": openAIMessages,
                "max_tokens": 400,
                "response_format": [ "type": "json_object" ]
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "ChatAppError", code: 4,
                              userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
            }
            guard httpResponse.statusCode == 200 else {
                let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                throw NSError(domain: "ChatAppError", code: 2,
                              userInfo: [NSLocalizedDescriptionKey:
                                            "OpenAI API request failed with status \(httpResponse.statusCode). Response: \(responseString)"])
            }

            struct OpenAIResponse: Decodable {
                struct Choice: Decodable {
                    struct Message: Decodable { let content: String }
                    let message: Message
                }
                let choices: [Choice]
            }

            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let firstChoice = openAIResponse.choices.first else {
                throw NSError(domain: "ChatAppError", code: 3,
                              userInfo: [NSLocalizedDescriptionKey: "No valid response from OpenAI API"])
            }
            return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    
    func saveDraftToFirebase() {
        print("Starting to save to Firebase...")
        guard let userID = Auth.auth().currentUser?.uid
            else {
                print("User is not authenticated.")
                return
        }
        guard !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                print("Empty draft. Not saving")
                return
        }
        
        let newDraft = Draft(
            id: UUID().uuidString,
            userID: userID,
            title: String(draftText.prefix(20)),
            content: draftText,
            timestamp: Date(),
            isFavorited: isFavorited,
            isHidden: false,
            isArchived: false,
            isPublished: false,
            prompt: prompt
        )
        
        Task {
            print("Saved to Firebase")
            self.draftText = ""
            await userViewModel.addDraft(newDraft)
            self.isFavorited = false
            self.isEditing = false
        }
    }
}
