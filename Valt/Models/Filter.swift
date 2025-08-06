import Foundation

enum Filter: String, CaseIterable, Identifiable {
    case mostRecent = "Most Recent"
    case favorites = "Favorites"
    case hidden = "Hidden"
    
    var id: Self { self }
}
