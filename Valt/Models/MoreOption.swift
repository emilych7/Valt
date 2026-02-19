import Foundation

enum MoreOption: String, CaseIterable, Identifiable {
    case publish = "Publish"
    case unpublish = "Unpublish"
    case hide = "Hide"
    case delete = "Delete"
    case archive = "Archive"
    case unarchive = "Unarchive"

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .publish:
            return "publishIcon"
        case .unpublish:
            return "publishIcon"
        case .hide:
            return "hideIcon"
        case .delete:
            return "deleteIcon"
        case .archive:
            return "archiveIcon"
        case .unarchive:
            return "archiveIcon"
        }
    }
}

