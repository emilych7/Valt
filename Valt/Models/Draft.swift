import Foundation

struct Draft: Identifiable {
    var id: String
    var userID: String
    var title: String
    var content: String
    var timestamp: Date
    var isFavorited: Bool
    var isHidden: Bool
    var isArchived: Bool
    var isPublished: Bool
    var isPrompted: Bool
    
    // Allows updating a field by name
    mutating func updateField(key: String, value: Any) {
        switch key {
        case "title":
            self.title = value as? String ?? self.title
        case "content":
            self.content = value as? String ?? self.content
        case "timestamp":
            if let date = value as? Date {
                self.timestamp = date
            }
        case "isFavorited":
            self.isFavorited = value as? Bool ?? self.isFavorited
        case "isHidden":
            self.isHidden = value as? Bool ?? self.isHidden
        case "isArchived":
            self.isArchived = value as? Bool ?? self.isArchived
        case "isPublished":
            self.isPublished = value as? Bool ?? self.isPublished
        case "isPrompted":
            self.isPrompted = value as? Bool ?? self.isPrompted
        default:
            break
        }
    }
}
