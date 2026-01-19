import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

final class OnBoardingViewModel: ObservableObject {
    @Published var offset: CGFloat = 0

    private let screenWidth = UIScreen.main.bounds.width
    private let screenBounds = UIScreen.main.bounds

    func getRotation() -> Double {
        let progress = offset / (screenWidth * 4)
        return Double(progress) * 360
    }

    func getIndex() -> Int {
        let progress = (offset / screenWidth).rounded()
        return Int(progress)
    }
    
    func getScreenBounds() -> CGRect {
        return screenBounds
    }
    
    func resetOnboarding() {
        self.offset = 0
    }
}
