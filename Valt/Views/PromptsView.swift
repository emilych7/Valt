import SwiftUI
import FirebaseAuth

struct Message: Identifiable, Equatable {
    let id = UUID()
    let sender: Sender
    let content: String
    let timestamp: Date

    // Defines who sent the message
    enum Sender: String {
        case user = "You"
        case ai = "AI"
    }
}

struct PromptsView: View {
    // MARK: - State Properties
    @State private var generatedPrompt: String = "Come back when you have at least 3 notes..."
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("PromptGen")
                    .font(.custom("OpenSans-SemiBold", size: 24))
                Spacer()
            }
            .padding(.leading, 25)
            .padding(.top, 20)
            .padding(.trailing, 25)
            
            HStack (spacing: 15) {
                ZStack {
                    Text(generatedPrompt)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor"))
                        .padding(10)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("BubbleColor"))
                        .stroke(Color("BorderColor"), lineWidth: 1)
                }
                .frame(maxWidth: .infinity, maxHeight: 75)
            }
            .padding(.horizontal, 20)
            
            // TODO: Add loading feature
            /*
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                Text(generatedPrompt)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
             */
            
            HStack (spacing: 15) {
                
                
                ZStack {
                    Rectangle()
                        .frame(width: 150, height: 45)
                        .cornerRadius(12)
                        .foregroundColor(Color("BubbleColor"))
                    Button(action: {
                        // StartWritingView()
                    }
                    ) {
                        HStack (spacing: 5) {
                            Text("Start Writing")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                                .foregroundColor(Color("TextColor"))
                            Image("Write")
                                .frame(width: 15, height: 15)
                        }
                    }
                    
                }
                
                ZStack {
                    Rectangle()
                        .frame(width: 150, height: 45)
                        .cornerRadius(12)
                        .foregroundColor(Color("BubbleColor"))
                    Button(action: {
                        generatePromptFromDrafts()
                    }
                    ) {
                        HStack (spacing: 5) {
                            Text("New Prompt")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                                .foregroundColor(Color("TextColor"))
                            Image("Refresh")
                                .frame(width: 15, height: 15)
                        }
                    }
                    
                }

                
                
                
                /*
                Button(action: generatePromptFromDrafts) {
                    ZStack {
                        HStack (spacing: 5) {
                            Text("Start Writing")
                                .font(.custom("OpenSans-SemiBold", size: 15))
                                .foregroundColor(.white)
                            Image("Write")
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                        }
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("ButtonColor"))
                    }
                }
                .disabled(isLoading)
                
                Button(action: generatePromptFromDrafts) {
                    Label("New Prompt", systemImage: "wand.and.stars")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                
                */
            }
            .padding(.horizontal, 20)

            Spacer()

        }
        .background(Color("AppBackgroundColor"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Private Helper Functions
    private func generatePromptFromDrafts() {
        self.isLoading = true

        // 1. Get the current user's ID from Firebase Auth.
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not logged in.")
            DispatchQueue.main.async {
                self.generatedPrompt = "Please log in to generate a personalized prompt."
                self.isLoading = false
            }
            return
        }

        // 2. Fetch drafts for the logged-in user.
        fetchDrafts(for: userID) { drafts in
            guard !drafts.isEmpty else {
                print("No drafts found for user. Cannot generate a prompt.")
                DispatchQueue.main.async {
                    self.generatedPrompt = "You don't have any drafts yet. Write something first to get a personalized prompt!"
                    self.isLoading = false
                }
                return
            }

            // TODO: Save prompts so that they are not asked again.
            // 3. Format the drafts into a single context string.
            let draftContext = drafts.map { draft in
                "Title: \(draft.title)\nContent: \(draft.content)"
            }.joined(separator: "\n\n---\n\n")

            // 4. Create a "meta-prompt" instructing the AI.
            let metaPrompt = """
            Based on the themes and content of the following writing drafts, please generate a single, new, and creative writing prompt that is thematically related. The new prompt should inspire a completely new story, or continue an existing one. The new prompt should also be framed as a question for the user that gets them to respond in the first person as a personal narrative. The new prompt should be less formal and more like a friend/therapist, who is 25 years old and a mental health advocate, is talking to me. The new prompt should be mindful to encourage the user to get more insight on themselves. The user should feel like the question is extremely personalized for them. Make the prompt no longer than 15 words and only one question.

            Here are the existing drafts for context:
            \(draftContext)

            New Creative Prompt:
            """
            
            let initialMessage = Message(sender: .user, content: metaPrompt, timestamp: Date())

            // 5. Call the ChatGPT API asynchronously.
            Task {
                do {
                    let apiResponse = try await callChatGPTAPI(history: [initialMessage])
                    // 6. Update the UI on the main thread with the result.
                    DispatchQueue.main.async {
                        self.generatedPrompt = apiResponse
                        self.isLoading = false
                    }
                } catch {
                    print("Error calling ChatGPT API: \(error)")
                    DispatchQueue.main.async {
                        self.generatedPrompt = "Failed to generate prompt. Error: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func callChatGPTAPI(history: [Message]) async throws -> String {
        // IMPORTANT: Replace with your actual OpenAI API Key.
        // For production apps, store this securely (e.g., in environment variables or a backend).
        
        let urlString = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "ChatAppError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid OpenAI API URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Constants.openAIAPIKey)", forHTTPHeaderField: "Authorization")

        let openAIMessages: [[String: String]] = history.map { message in
            var role: String
            switch message.sender {
            case .user:
                role = "user"
            case .ai:
                role = "assistant"
            }
            return ["role": role, "content": message.content]
        }

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": openAIMessages,
            "max_tokens": 150
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let responseString = String(data: data, encoding: .utf8) ?? "No response data"
            print("OpenAI API Error: Status Code \(statusCode), Response: \(responseString)")
            throw NSError(domain: "ChatAppError", code: 2, userInfo: [NSLocalizedDescriptionKey: "OpenAI API request failed with status \(statusCode). Response: \(responseString)"])
        }

        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        if let firstChoice = openAIResponse.choices.first {
            return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw NSError(domain: "ChatAppError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No valid response from OpenAI API"])
        }
    }
}

#Preview {
    PromptsView()
}
