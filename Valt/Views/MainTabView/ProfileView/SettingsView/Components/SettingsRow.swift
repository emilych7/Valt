import SwiftUI

struct SettingsRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 15, height: 15)
            
            Text(title)
                .font(.custom("OpenSans-Regular", size: 17))
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            Image("rightArrowIcon")
                .resizable()
                .frame(width: 14, height: 14)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        
    }
    
}
