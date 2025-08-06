import SwiftUI

class BannerManager: ObservableObject {
    @Published var message: String = ""
    @Published var isVisible: Bool = false
    @Published var backgroundColor: Color = Color("RequestButtonColor")
    @Published var icon: String? = nil
    @Published var position: BannerPosition = .top

    enum BannerPosition {
        case top, center, bottom
    }

    func show(_ message: String,
              duration: Double = 2.0,
              backgroundColor: Color = Color("RequestButtonColor"),
              icon: String? = nil,
              position: BannerPosition = .center) { 
        self.message = message
        self.backgroundColor = backgroundColor
        self.icon = icon
        self.position = position
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            self.isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self.isVisible = false
            }
        }
    }
}
