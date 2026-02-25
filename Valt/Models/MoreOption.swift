import Foundation

enum MoreOption: String, CaseIterable, Identifiable {
    case publish = "Publish"
    case unpublish = "Unpublish"
    case hide = "Hide"
    case unhide = "Unhide"
    case archive = "Archive"
    case unarchive = "Unarchive"
    case delete = "Delete"

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .publish:
            return "publishIcon"
        case .unpublish:
            return "publishIcon"
        case .hide:
            return "hideIcon"
        case .unhide:
            return "hideIcon"
        case .archive:
            return "archiveIcon"
        case .unarchive:
            return "archiveIcon"
        case .delete:
            return "trashIcon"
        }
    }
}

