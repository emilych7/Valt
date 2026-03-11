import SwiftUI

enum EditFieldType {
    case username
    case email
    
    var title: String {
        switch self {
        case .username: return "Update Username"
        case .email: return "Update Email"
        }
    }
    
    var subtitle: String {
        switch self {
        case .username: return "Username"
        case .email: return "Email"
        }
    }
    
    var subtitle2: String {
        switch self {
        case .username: return "You can edit your username up to 5 times in 30 minutes."
        case .email: return "You can edit your email up to 5 times in 30 minutes."
        }
    }
    
    var placeholder: String {
        switch self {
        case .username: return "Username"
        case .email: return "Email"
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        default: return .default
        }
    }
}
