import SwiftUI

struct CustomHeader: View {
    let title: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 24))
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            Button(action: action) {
                HStack(spacing: 5) {
                    Image("exitDynamicIcon")
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Text(buttonTitle)
                        .font(.custom("OpenSans-SemiBold", size: 15))
                        .foregroundColor(Color("TextColor"))
                }
                .padding(.vertical, 3)
                .padding(.horizontal, 8)
                .background(Color("BubbleColor"))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .padding(.top, 15)
        .background(Color("AppBackgroundColor"))
    }
}
