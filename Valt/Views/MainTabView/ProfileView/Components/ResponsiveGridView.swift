import SwiftUI

struct ResponsiveGridView<Content: View, T: Identifiable>: View {
    let items: [T]
    let content: (T) -> Content
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(items) { item in
                    content(item)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
        }
        .scrollIndicators(.hidden)
    }
}
