import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var generatedPrompts: [String] = []
    @Published var isLoading: Bool = true
    @Published var showPrompts: Bool = false
    @Published var isPromptSelected: Bool = false

    @Published var isEditing = false
    @Published var isFavorited = false
    @Published var prompt: String? = nil
    @Published var draftText = ""
    @Published var animateItems: Bool = false
    
    private let userViewModel: UserViewModel
    private let repository: DraftRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    init(userViewModel: UserViewModel, repository: DraftRepositoryProtocol = DraftRepository()) {
        self.userViewModel = userViewModel
        self.repository = repository
    }

    func generatePromptFromOwnDrafts(with drafts: [Draft]) {
        guard drafts.count >= 3 else {
            self.generatedPrompts = []
            self.isLoading = false
            self.showPrompts = false
            self.animateItems = false
            return
        }
        
        guard generatedPrompts.isEmpty else {
            self.animateItems = true
            self.isLoading = false
            return
        }

        print("Generating prompts for the first time with \(drafts.count) drafts...")
        self.isLoading = true
        self.animateItems = false
        self.generatePrompt(from: drafts)
    }

    // Manual refresh
    func refreshPrompts(with drafts: [Draft]) {
        isLoading = true
        self.animateItems = false
        self.generatedPrompts = []
        generatePromptFromOwnDrafts(with: drafts)
    }

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
                * **Tone:** The question should sound like it's coming from a bestfriend seeking a psychological perspective. It should be easy to understand for an 18-24 year old demographic.
                * **Goal:** Inspire the user to expand on themes from their drafts.
            3.  **Output Format:** Your response MUST be a single JSON object with a single key named "prompts".
        
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
                
                guard let jsonData = jsonString.data(using: .utf8) else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"])
                }

                struct PromptResponse: Decodable {
                    let prompts: [String]
                }

                let response = try JSONDecoder().decode(PromptResponse.self, from: jsonData)
                
                // Update UI state on the MainActor
                self.generatedPrompts = response.prompts
                self.showPrompts = true
                self.isLoading = false
                
                try? await Task.sleep(for: .milliseconds(50))
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.animateItems = true
                }
                
            } catch {
                print("Error calling ChatGPT API:", error.localizedDescription)
                self.generatedPrompts = ["Failed to generate prompt. Error: \(error.localizedDescription)"]
                self.isLoading = false
                self.animateItems = true
            }
        }
    }
    
    // OPENAI
    func callChatGPTAPI(history: [PromptMessage]) async throws -> String {
        let urlString = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "ChatAppError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Constants.OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")

        let openAIMessages: [[String: String]] = history.map { message in
            ["role": (message.sender == .user) ? "user" : "assistant", "content": message.content]
        }

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": openAIMessages,
            "max_tokens": 400,
            "response_format": [ "type": "json_object" ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "ChatAppError", code: 2, userInfo: [NSLocalizedDescriptionKey: "API Error"])
        }

        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String }
                let message: Message
            }
            let choices: [Choice]
        }

        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return openAIResponse.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func saveDraftToFirebase() {
        saveDraftLogic(promptValue: nil)
    }

    func savePromptedDraftToFirebase() {
        saveDraftLogic(promptValue: self.prompt)
    }

    private func saveDraftLogic(promptValue: String?) {
        guard let userID = Auth.auth().currentUser?.uid,
              !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
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
            prompt: promptValue
        )
        
        Task {
            self.draftText = ""
            await userViewModel.addDraft(newDraft)
            self.isFavorited = false
            self.isEditing = false
        }
    }
}
