import Foundation

protocol OpenAIServiceProtocol {
    func callChatGPTAPI(history: [PromptMessage]) async throws -> String
}

final class OpenAIService: OpenAIServiceProtocol {
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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "ChatAppError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid server response."])
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("OpenAI API returned HTTP \(httpResponse.statusCode): \(errorBody)")
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorDict = json["error"] as? [String: Any],
               let message = errorDict["message"] as? String {
                throw NSError(domain: "ChatAppError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "\(message) (HTTP \(httpResponse.statusCode))"])
            }
            
            throw NSError(domain: "ChatAppError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorBody)"])
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
}
