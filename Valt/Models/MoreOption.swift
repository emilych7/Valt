import Foundation

enum MoreOption: String, CaseIterable, Identifiable {
    case hide = "Hide"
    case delete = "Delete"
    case archive = "Archive"
    

    var id: Self { self }
}
