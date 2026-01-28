import SwiftUI

struct FullNotePreview: View {
    let draft: Draft
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(draft.timestamp.formatted(.dateTime.month().day().year()))
                    .font(.caption)
                    .opacity(0.6)
                
                Spacer()
            }
            
            if let promptText = draft.prompt {
                Text(promptText)
                    .font(.custom("OpenSans-SemiBold", size: 15))
                    .foregroundColor(Color("TextColor").opacity(0.7))
            }
            
            Text(draft.content)
                .font(.custom("OpenSans-Regular", size: 14))
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
        .background(Color("CardColor"))
    }
}
