import SwiftUI

class BannerManager: ObservableObject {
    @Published var message: String = ""
    @Published var isVisible: Bool = false

    func show(_ message: String, duration: Double = 3.0) {
        self.message = message
        withAnimation {
            self.isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isVisible = false
            }
        }
    }
}
