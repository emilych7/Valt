import Foundation

struct OtherUser: Identifiable, Codable, Equatable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var publishedDrafts: [Draft]
    var hasProfilePicture: Bool {
        return profileImageUrl != nil && !(profileImageUrl?.isEmpty ?? true)
    }
}
