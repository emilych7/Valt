import SwiftUI

enum EditFieldType {
    case username
    case email
    case phone
    
    var title: String {
        switch self {
        case .username: return "Update Username"
        case .email: return "Update Email"
        case .phone: return "Update Phone"
        }
    }
    
    var subtitle: String {
        switch self {
        case .username: return "Username"
        case .email: return "Email"
        case .phone: return "Phone Number"
        }
    }
    
    var subtitle2: String {
        switch self {
        case .username: return "Without a username, you won't be able to publish drafts or search profiles."
        case .email: return "Your email has not been verified. Verify now."
        case .phone: return "Your phone number has not been verified. Verify now."
        }
    }
    
    var placeholder: String {
        switch self {
        case .username: return "Username"
        case .email: return "Email"
        case .phone: return "Phone Number"
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        case .phone: return .phonePad
        default: return .default
        }
    }
}
