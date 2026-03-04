import SwiftUI

struct Header: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 24))
                .foregroundColor(Color("TextColor"))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .padding(.top, 15)
    }
}
