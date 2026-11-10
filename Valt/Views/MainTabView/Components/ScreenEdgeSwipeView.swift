import SwiftUI
import UIKit

struct ScreenEdgeSwipeView: UIViewRepresentable {
    var edgeMargin: CGFloat = 36.0
    var canSwipeLeft: Bool = true
    var canSwipeRight: Bool = true
    var onDragChanged: ((CGFloat) -> Void)? = nil
    var onDragEnded: ((CGFloat, CGFloat) -> Void)? = nil
    var onSwipeLeft: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = TouchPassingView(
            edgeMargin: edgeMargin,
            canSwipeLeft: canSwipeLeft,
            canSwipeRight: canSwipeRight
        )
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        
        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        pan.delegate = context.coordinator
        pan.cancelsTouchesInView = true
        view.addGestureRecognizer(pan)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self
        if let touchView = uiView as? TouchPassingView {
            touchView.edgeMargin = edgeMargin
            touchView.canSwipeLeft = canSwipeLeft
            touchView.canSwipeRight = canSwipeRight
        }
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ScreenEdgeSwipeView
        private var startedAtLeftEdge: Bool = false
        private var startedAtRightEdge: Bool = false
        private var lastTriggerTime: Date = .distantPast
        
        init(_ parent: ScreenEdgeSwipeView) {
            self.parent = parent
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
                  let view = pan.view else { return false }
            
            let point = pan.location(in: view)
            let width = view.bounds.width
            let margin = parent.edgeMargin
            
            let isLeft = point.x <= margin
            let isRight = point.x >= (width - margin)
            
            guard isLeft || isRight else { return false }
            
            if isLeft && !parent.canSwipeRight { return false }
            if isRight && !parent.canSwipeLeft { return false }
            
            let velocity = pan.velocity(in: view)
            guard abs(velocity.x) > abs(velocity.y) else { return false }
            
            if isLeft && velocity.x <= 0 { return false }
            if isRight && velocity.x >= 0 { return false }
            
            return true
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return false
        }
        
        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            guard let view = recognizer.view else { return }
            let touchView = view as? TouchPassingView
            let translation = recognizer.translation(in: view)
            let velocity = recognizer.velocity(in: view)
            let width = view.bounds.width
            
            switch recognizer.state {
            case .began:
                touchView?.isDragging = true
                let point = recognizer.location(in: view)
                let margin = parent.edgeMargin
                startedAtLeftEdge = point.x <= margin
                startedAtRightEdge = point.x >= (width - margin)
                
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                parent.onDragChanged?(0)
                
            case .changed:
                var offset: CGFloat = 0
                if startedAtLeftEdge {
                    offset = max(0, min(width, translation.x))
                } else if startedAtRightEdge {
                    offset = min(0, max(-width, translation.x))
                }
                parent.onDragChanged?(offset)
                
            case .ended:
                var offset: CGFloat = 0
                if startedAtLeftEdge {
                    offset = max(0, min(width, translation.x))
                } else if startedAtRightEdge {
                    offset = min(0, max(-width, translation.x))
                }
                
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
                if let onDragEnded = parent.onDragEnded {
                    onDragEnded(offset, velocity.x)
                } else {
                    let now = Date()
                    guard now.timeIntervalSince(lastTriggerTime) > 0.3 else { return }
                    if startedAtLeftEdge && (offset > 35 || velocity.x > 250) {
                        lastTriggerTime = now
                        parent.onSwipeRight?()
                    } else if startedAtRightEdge && (offset < -35 || velocity.x < -250) {
                        lastTriggerTime = now
                        parent.onSwipeLeft?()
                    }
                }
                
                startedAtLeftEdge = false
                startedAtRightEdge = false
                
                DispatchQueue.main.async {
                    touchView?.isDragging = false
                }
                
            case .cancelled, .failed:
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                parent.onDragEnded?(0, 0)
                startedAtLeftEdge = false
                startedAtRightEdge = false
                DispatchQueue.main.async {
                    touchView?.isDragging = false
                }
                
            default:
                break
            }
        }
    }
    
    final class TouchPassingView: UIView {
        var edgeMargin: CGFloat
        var canSwipeLeft: Bool
        var canSwipeRight: Bool
        var isDragging: Bool = false
        
        init(edgeMargin: CGFloat, canSwipeLeft: Bool = true, canSwipeRight: Bool = true) {
            self.edgeMargin = edgeMargin
            self.canSwipeLeft = canSwipeLeft
            self.canSwipeRight = canSwipeRight
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            self.edgeMargin = 36.0
            self.canSwipeLeft = true
            self.canSwipeRight = true
            super.init(coder: coder)
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            if isDragging {
                return true
            }
            let isLeft = point.x <= edgeMargin
            let isRight = point.x >= (bounds.width - edgeMargin)
            
            if isLeft && canSwipeRight { return true }
            if isRight && canSwipeLeft { return true }
            return false
        }
    }
}

extension View {
    func onScreenEdgeSwipe(
        edgeMargin: CGFloat = 36.0,
        canSwipeLeft: Bool = true,
        canSwipeRight: Bool = true,
        onDragChanged: ((CGFloat) -> Void)? = nil,
        onDragEnded: ((CGFloat, CGFloat) -> Void)? = nil,
        onSwipeLeft: (() -> Void)? = nil,
        onSwipeRight: (() -> Void)? = nil
    ) -> some View {
        overlay(
            ScreenEdgeSwipeView(
                edgeMargin: edgeMargin,
                canSwipeLeft: canSwipeLeft,
                canSwipeRight: canSwipeRight,
                onDragChanged: onDragChanged,
                onDragEnded: onDragEnded,
                onSwipeLeft: onSwipeLeft,
                onSwipeRight: onSwipeRight
            )
        )
    }
}
