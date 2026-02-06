import SwiftUI

struct HomeActionButton: View {
    let icon: String
    var backgroundColor: String = "BubbleColor"
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(backgroundColor))
                
                if isLoading {
                    ProgressView()
                        .frame(width: 20, height: 20)
                } else {
                    Image(icon)
                        .opacity(icon.contains("Inactive") ? 0.5 : 1)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
