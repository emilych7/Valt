import Foundation
import SwiftUI

enum ContentTabViewSelection {
    case profile
    case home
    case explore

    var label: some View {
        switch self {
        case .profile:
            return Label("Profile", image: "profileIcon")
        case .home:
            return Label("Create", image: "createIcon")
        case .explore:
            return Label("Explore", image: "promptsIcon")
        }
    }

    var index: Int {
        switch self {
        case .explore: return 0
        case .home: return 1
        case .profile: return 2
        }
    }

    var previous: ContentTabViewSelection? {
        switch self {
        case .explore:
            return nil
        case .home:
            return .explore
        case .profile:
            return .home
        }
    }
    
    var next: ContentTabViewSelection? {
        switch self {
        case .explore:
            return .home
        case .home:
            return .profile
        case .profile:
            return nil
        }
    }
}

