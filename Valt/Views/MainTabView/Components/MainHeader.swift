import SwiftUI

struct MainHeader: View {
    let title: String
    var image: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 24))
            
            Spacer()
            
            if let imageName = image, let buttonAction = action {
                Button(action: buttonAction) {
                    ZStack {
                        Ellipse()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("BubbleColor"))
                        Image(imageName)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .background(Color("AppBackgroundColor"))
    }
}
