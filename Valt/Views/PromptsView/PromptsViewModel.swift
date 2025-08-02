import Foundation
import FirebaseAuth

@MainActor
final class PromptsViewModel: ObservableObject {
    
    @Published var generatedPrompt: String = "Come back when you have at least 3 notes..."
    @Published var isLoading: Bool = false
    
    private let repository: DraftRepositoryProtocol
        
    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
    }
    
    func generatePromptFromDrafts() {
        print("DEBUG: generatePromptFromDrafts() called")
        isLoading = true

        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            generatedPrompt = "Please log in to generate a personalized prompt."
            isLoading = false
            return
        }

        // 2. Fetch drafts for the logged-in user.
        repository.fetchDrafts(for: userID) { [weak self] drafts in
            guard let self = self else { return }
            
            guard !drafts.isEmpty else {
                print("No drafts found for user. Cannot generate a prompt.")
                self.generatedPrompt = "Create at least five drafts to get a personalized prompt!"
                self.isLoading = false
                return
            }

            // 3. Combine all drafts into a context string.
            let draftContext = drafts.map { draft in
                "Title: \(draft.title)\nContent: \(draft.content)"
            }.joined(separator: "\n\n---\n\n")

            // 4. Build the meta-prompt with your detailed instructions.
            let metaPrompt = """
            Based on the themes and content of the following drafts, please generate a single, new, and creative writing prompt that is related. The new prompt should inspire the reader to want to expand on the strongest themes and deepest content from the drafts. The new prompt should also be framed as a question that gets them to respond in the first person like a personal narrative or diary entry. The goal of the new prompt is to encourage the reader to reveal more about their thoughts and feelings, so they can save the note for review later. The user should feel like the question is personalized for them. It should not be generic. Make the prompt no longer than 15 words and only one question.
            
            The question should read like it is coming from a 25-year old best friend who listens to you and offers insightful questions like your therapist. Give abstraction to the question. Make it easy to understand for a demographic of 18 to 30 year olds. 

            Here are the existing drafts for context:
            \(draftContext)

            New Creative Prompt:
            """
            
            let initialMessage = Message(sender: .user, content: metaPrompt, timestamp: Date())

            // 5. Call the ChatGPT API asynchronously.
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let apiResponse = try await self.callChatGPTAPI(history: [initialMessage])
                    await MainActor.run {
                        self.generatedPrompt = apiResponse
                        self.isLoading = false
                    }
                } catch {
                    print("Error calling ChatGPT API: \(error)")
                    await MainActor.run {
                        self.generatedPrompt = "Failed to generate prompt. Error: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }

        }
    }
    
    func callChatGPTAPI(history: [Message]) async throws -> String {

        
        
        let urlString = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "ChatAppError", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid OpenAI API URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Constants.openAIAPIKey)", forHTTPHeaderField: "Authorization")

        let openAIMessages: [[String: String]] = history.map { message in
            let role: String = (message.sender == .user) ? "user" : "assistant"
            return ["role": role, "content": message.content]
        }

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": openAIMessages,
            "max_tokens": 150
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: Status code -> \(httpResponse.statusCode)")
        }

        if let rawResponse = String(data: data, encoding: .utf8) {
            print("DEBUG: Raw API response -> \(rawResponse)")
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let responseString = String(data: data, encoding: .utf8) ?? "No response data"
            print("OpenAI API Error: Status Code \(statusCode), Response: \(responseString)")
            throw NSError(domain: "ChatAppError", code: 2,
                          userInfo: [NSLocalizedDescriptionKey:
                                     "OpenAI API request failed with status \(statusCode). Response: \(responseString)"])
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
