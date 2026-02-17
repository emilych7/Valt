import SwiftUI

struct OtherUserHeader: View {
    @Environment(\.dismiss) var dismiss
    let username: String
    var image: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color("ValtRed"))
                    Image("exitIcon")
                        .frame(width: 20, height: 20)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Text(username)
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
