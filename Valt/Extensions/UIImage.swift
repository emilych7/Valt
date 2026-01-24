import UIKit
import SwiftUI

extension UIImage {
    func createTabItemLabelFromImage(_ isSelected: Bool) -> UIImage? {
        let imageSize = CGSize(width: 24, height: 24)
        
        return UIGraphicsImageRenderer(size: imageSize).image { context in
            let rect = CGRect(origin: .zero, size: imageSize)
            let clipPath = UIBezierPath(ovalIn: rect)
            
            context.cgContext.saveGState()
            
            clipPath.addClip()
            self.draw(in: rect)
            
            context.cgContext.restoreGState()
            
            if isSelected {
                let strokeThickness: CGFloat = 1
                let strokeRect = rect.insetBy(dx: strokeThickness / 2, dy: strokeThickness / 2)
                let strokePath = UIBezierPath(ovalIn: strokeRect)
                
                if let textColor = UIColor(named: "TextColor") {
                    textColor.setStroke()
                } else {
                    UIColor.black.setStroke() // Fallback
                }
                
                strokePath.lineWidth = strokeThickness
                strokePath.stroke()
            }
        }.withRenderingMode(.alwaysOriginal)
    }
}
