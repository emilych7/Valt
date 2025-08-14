import Foundation

struct PromptItem: Identifiable, Hashable, Codable {
    let id: UUID
    let icon: String
    let text: String
    
    init(id: UUID = UUID(), icon: String = "editIcon", text: String) {
        self.id = id
        self.icon = icon
        self.text = text
    }
}

struct PromptResponse: Codable {
    let prompts: [PromptItem]
}
