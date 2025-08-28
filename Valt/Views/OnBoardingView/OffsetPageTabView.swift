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
        
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(host.view)

        // Use content/frame layout guides (safer than pinning to scrollView directly)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            host.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // Avoid fighting user scroll and avoid delegate echo
        guard !scrollView.isDragging,
              !scrollView.isDecelerating,
              !context.coordinator.isProgrammaticUpdate else { return }
        
        if scrollView.contentOffset.x != offset {
            context.coordinator.isProgrammaticUpdate = true
            // don’t animate; animation can re-enter mid-update
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
            context.coordinator.isProgrammaticUpdate = false
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: OffsetPageTabView
        var isProgrammaticUpdate = false
        
        init(_ parent: OffsetPageTabView) { self.parent = parent }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard !isProgrammaticUpdate else { return }
            let x = scrollView.contentOffset.x
            // Publish on next run loop to avoid “Publishing changes from within view updates…”
            DispatchQueue.main.async {
                if self.parent.offset != x {
                    self.parent.offset = x
                }
            }
        }
    }
}
