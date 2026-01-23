import SwiftUI

struct HomeActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("BubbleColor"))
                Image(icon)
                    .opacity(icon.contains("Inactive") ? 0.5 : 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
