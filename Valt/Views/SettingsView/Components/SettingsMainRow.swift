import SwiftUI

struct SettingsMainRow: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
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
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
        
    }
    
}
