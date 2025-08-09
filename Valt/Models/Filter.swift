import Foundation

enum Filter: String, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case hidden = "Hidden"
    case published = "Published"
    
    var id: Self { self }
}
