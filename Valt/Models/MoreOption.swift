import Foundation

enum MoreOption: String, CaseIterable, Identifiable {
    case edit = "Edit"
    case publish = "Publish"
    case hide = "Hide"
    case delete = "Delete"

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .edit:
            return "editIcon"
        case .publish:
            return "publishIcon"
        case .hide:
            return "hideIcon"
        case .delete:
            return "deleteIcon"
        }
    }
}

