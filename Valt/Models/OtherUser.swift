import Foundation

struct OtherUser: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var username: String
    var profileImageURL: String
    var publishedDrafts: [Draft]
    
    var hasProfilePicture: Bool {
        !profileImageURL.isEmpty
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // How to compare two users
    static func == (lhs: OtherUser, rhs: OtherUser) -> Bool {
        lhs.id == rhs.id
    }
}
