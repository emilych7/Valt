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
}

