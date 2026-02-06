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
              duration: Double = 1.0,
              backgroundColor: Color = Color("AuthOptionsBackground"),
              icon: String? = nil,
              position: BannerPosition = .top) {
        self.message = message
        self.backgroundColor = backgroundColor
        self.icon = icon
        self.position = position
        
        withAnimation (.smooth(duration: 0.13)) {
            self.isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation (.smooth(duration: 0.13)){
                self.isVisible = false
            }
        }
    }
}
