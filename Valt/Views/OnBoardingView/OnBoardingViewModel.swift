import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

final class OnBoardingViewModel: ObservableObject {
    @State var offset: CGFloat = 0
    
    func getRotation() -> Double {
        let progress = offset / (getScreenBounds().width * 4)
        return Double(progress) * 360
    }

    func getIndex() -> Int {
        let progress = (offset / getScreenBounds().width).rounded()
        return Int(progress)
    }
    
    func getScreenBounds() -> CGRect {
        UIScreen.main.bounds
    }
}
