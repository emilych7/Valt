import SwiftUI

struct ProfileActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("BubbleColor"))
                Image(icon)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
