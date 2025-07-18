import Foundation

struct Draft: Identifiable {
    var id: String
    var title: String
    var content: String
    var timestamp: Date
    var isFavorited: Bool
    var isHidden: Bool
}

