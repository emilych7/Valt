import SwiftUI

struct Socials: View {
    let title: String
    
    var onGoogleTap: () -> Void
    var onAppleTap: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .foregroundColor(Color("TextColor"))
                .font(.custom("OpenSans-Regular", size: 16))
                .padding(.top, 10)
            
            HStack(spacing: 25) {
                // Google Button
                Button(action: onGoogleTap) {
                    Image("Google")
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(Color("AuthOptionsBackground"), in: RoundedRectangle(cornerRadius: 12))
                }
                
                // Apple Button
                Button(action: onAppleTap) {
                    Image("appleIcon")
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(Color("AuthOptionsBackground"), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
