import Foundation
import FirebaseAuth

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var generatedPrompts: [String] = ["Come back when you have at least 3 notes..."]
    @Published var isLoading: Bool = false

    // Search state
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var usernameSuggestions: [String] = []
    @Published var selectedUsername: String? = nil
    @Published var publishedDraftsForUser: [Draft] = []

    private let repository: DraftRepositoryProtocol
    private var searchTask: Task<Void, Never>? // for debouncing

    init(repository: DraftRepositoryProtocol = DraftRepository()) {
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
                // Check for cancellation. If the task was cancelled, don't proceed.
                guard !Task.isCancelled else { return }
                
                if q.isEmpty {
                    self.usernameSuggestions = []
                    self.isSearching = false
                    return
                }

                // We are now searching, update the UI state.
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

    // Generate prompt from current user’s own drafts (async/await)
    func generatePromptFromOwnDrafts() {
        isLoading = true

        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            generatedPrompts = ["You need to be logged in."]
            isLoading = false
            return
        }

        Task { [weak self] in
            guard let self = self else { return }
            do {
                // ⬇️ Explicitly select the async overload
                let asyncFetch: (String) async throws -> [Draft] = self.repository.fetchDrafts
                let drafts = try await asyncFetch(userID)

                guard drafts.count >= 3 else {
                    self.generatedPrompts = ["Create at least three drafts to get a personalized prompt."]
                    self.isLoading = false
                    return
                }

                self.generatePrompt(from: drafts)
            } catch {
                print("Error fetching drafts:", error.localizedDescription)
                self.generatedPrompts = ["Failed to load your drafts."]
                self.isLoading = false
            }
        }
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
        
        Based on the themes and content of the following drafts, please generate 5 unique and creative writing prompt that is related. The new prompt should inspire the reader to want to expand on the strongest themes and deepest content from the drafts. The new prompt should also be framed as a question that gets them to respond in the first person like a personal narrative or diary entry. The goal of the new prompt is to encourage the reader to reveal more about their thoughts and feelings, so they can save the note for review later. The user should feel like the question is personalized for them. It should not be generic. Make the prompt no longer than 15 words and only one question.

        The question should read like it is coming from a 25-year old best friend who listens to you and offers insightful questions like your therapist. Give abstraction to the question. Make it easy to understand for a demographic of 18 to 30 year olds.
        
        Please respond with a JSON object that has a single key: "prompts". The value of "prompts" should be an array containing the generated prompt strings.

        Here are the existing drafts for context:
        \(draftContext)

        New Creative Prompt:
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

                // Decode the JSON data directly into your Swift object
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

        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !apiKey.isEmpty else {
            throw NSError(domain: "ChatAppError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Missing OpenAI API key in environment variables"])
        }
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let openAIMessages: [[String: String]] = history.map { message in
            let role = (message.sender == .user) ? "user" : "assistant"
            return ["role": role, "content": message.content]
        }

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": openAIMessages,
            "max_tokens": 150,
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
}
