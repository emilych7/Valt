import SwiftUI

class TabManager: ObservableObject {
    @Published var isTabBarHidden: Bool = false

    func setTabBarHidden(_ hidden: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.isTabBarHidden = hidden
        }
    }
}
