import SwiftUI

struct NavigationBar: View {
    var onBackTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBackTap) {
                Text("Back")
            }
            .font(.custom("OpenSans-SemiBold", size: 13))
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .tint(Color("BubbleColor").opacity(0.50))
            
            Spacer()
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 10)
        .background(Color("AppBackgroundColor"))
    }
}
