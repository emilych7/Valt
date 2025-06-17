import SwiftUI

struct CardView: View {
    let title: String
    let content: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 175, height: 255)
                .foregroundColor(Color("bubbleColor"))
            VStack (spacing: 10) {
                Text(title)
                    .font(.custom("OpenSans-SemiBold", size: 17))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(2)
                Text(content)
                    .font(.custom("OpenSans-Regular", size: 15))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(4)
            }
            .frame(width: 175, height: 255)
            .padding(10)
        }
    }
}
