import SwiftUI

struct CustomDivider: View {
    
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color("TextFieldBorder"))
            .padding(.horizontal, 15)
        
    }
    
}
