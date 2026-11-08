import SwiftUI

struct LargeProfilePictureView: View {
    @Environment(\.dismiss) var dismiss
    let profileImage: UIImage?
    
    var body: some View {
        ZStack {
            
            VStack {
                Spacer()
                
                HStack(){
                    Spacer()
                    
                    VStack (spacing: 5) {
                        Ellipse()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("AppBackgroundColor"))
                        
                        Text("Take Photo")
                            .foregroundStyle(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 15))
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack (spacing: 5) {
                        Ellipse()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("AppBackgroundColor"))
                        
                        Text("Library")
                            .foregroundStyle(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 15))
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack (spacing: 5) {
                        Ellipse()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color("AppBackgroundColor"))
                        
                        Text("Delete")
                            .foregroundStyle(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 15))
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
                .background(.red)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
            .background(Color("AppBackgroundColor").opacity(0.2))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                dismiss()
            }
            
            
            ZStack() {
                if let uiImage = profileImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipShape(Ellipse())
                } else {
                    placeholderView
                }
                
                Ellipse()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("AppBackgroundColor"))
                    .offset(x: 110, y: -115)
            }
            .padding(10)
        }
    }
    
    private var placeholderView: some View {
        Ellipse()
            .frame(width: 300, height: 300)
            .foregroundColor(Color("BubbleColor"))
            .overlay(
                Image(systemName: "camera.fill")
                    .foregroundColor(Color("TextColor"))
                    .font(.system(size: 20))
            )
    }
    
}

#Preview("With Image") {
    LargeProfilePictureView(
        profileImage: UIImage(systemName: "person.crop.circle.fill")
    )
}
