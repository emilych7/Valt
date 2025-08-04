import Foundation

enum MoreOption: String, CaseIterable, Identifiable {
    case hide = "Hide"
    case edit = "Edit"
    case delete = "Delete"
    case archive = "Archive"
    

    var id: Self { self }
}
