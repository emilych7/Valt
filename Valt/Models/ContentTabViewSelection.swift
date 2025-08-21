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
}

