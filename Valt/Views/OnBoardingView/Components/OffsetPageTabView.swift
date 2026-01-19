import SwiftUI

struct OffsetPageTabView<Content: View>: UIViewRepresentable {
    var content: Content
    @Binding var offset: CGFloat
    
    init(offset: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._offset = offset
        self.content = content()
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = context.coordinator
        
        // Allows the ScrollView to communicate with the system about the keyboard
        scrollView.contentInsetAdjustmentBehavior = .automatic
        
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        
        // Use the host's sizing
        host.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Fix the height to the frame
            host.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard !scrollView.isDragging, !scrollView.isDecelerating else { return }
        
        let roundedOffset = round(offset)
        let roundedScroll = round(scrollView.contentOffset.x)
        
        
        if abs(roundedOffset - roundedScroll) > 1 && !scrollView.isDragging && !scrollView.isDecelerating {
            context.coordinator.isProgrammaticUpdate = true
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
            context.coordinator.isProgrammaticUpdate = false
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
            var parent: OffsetPageTabView
            var isProgrammaticUpdate = false
            
            init(_ parent: OffsetPageTabView) {
                self.parent = parent
            }
            
            func scrollViewDidScroll(_ scrollView: UIScrollView) {
                guard scrollView.isDragging || scrollView.isDecelerating else { return }
                
                guard !isProgrammaticUpdate else { return }
                let x = scrollView.contentOffset.x
                
                // Only update if there is a significant change to prevent jitter
                if abs(parent.offset - x) > 0.5 {
                    DispatchQueue.main.async {
                        self.parent.offset = x
                    }
                }
            }
        }
}
