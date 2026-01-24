import SwiftUI

struct CustomDivider: View {
    
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("TextColor").opacity(0.2))
            .padding(.horizontal, 15)
        
    }
    
}
