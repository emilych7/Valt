import SwiftUI

struct CardView: View {
    let title: String
    let content: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 175, height: 255)
                .foregroundColor(Color(""))
            VStack (alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.custom("OpenSans-SemiBold", size: 14))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(2)
                Text(content)
                    .font(.custom("OpenSans-Regular", size: 10))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(4)
            }
            .padding(10)
            .frame(width: 175, height: 255)
        }
    }
}
