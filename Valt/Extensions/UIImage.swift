import UIKit
import SwiftUI

extension UIImage {
    func createTabItemLabelFromImage(_ isSelected: Bool) -> UIImage? {
        let imageSize = CGSize(width: 25, height: 25)
        
        return UIGraphicsImageRenderer(size: imageSize).image { context in
            let rect = CGRect(origin: .zero, size: imageSize)
            
            // Create the circular clip
            let clipPath = UIBezierPath(ovalIn: rect)
            clipPath.addClip()
            
            let widthRatio = imageSize.width / self.size.width
            let heightRatio = imageSize.height / self.size.height
            let ratio = max(widthRatio, heightRatio)
            
            let newSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
            let drawRect = CGRect(
                x: (imageSize.width - newSize.width) / 2,
                y: (imageSize.height - newSize.height) / 2,
                width: newSize.width,
                height: newSize.height
            )
            
            self.draw(in: drawRect)
        }.withRenderingMode(.alwaysOriginal)
    }
}
