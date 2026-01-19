import SwiftUI

struct Header: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 30))
                .foregroundColor(Color("TextColor"))
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}
