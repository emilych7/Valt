import Foundation

struct PromptMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let sender: Sender
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), sender: Sender, content: String, timestamp: Date = Date()) {
        self.id = id
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
    }

    enum Sender: String, Codable {
        case user = "You"
        case ai   = "AI"
    }
}
