import Foundation

struct OtherUser: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var publishedDrafts: [Draft]
    
    var hasProfilePicture: Bool {
        return profileImageUrl != nil && !(profileImageUrl?.isEmpty ?? true)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // How to compare two users
    static func == (lhs: OtherUser, rhs: OtherUser) -> Bool {
        lhs.id == rhs.id
    }
}
