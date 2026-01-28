import SwiftUI

struct FullNotePreview: View {
    let draft: Draft
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(draft.timestamp.formatted(.dateTime.month().day().year()))
                .font(.caption)
                .opacity(0.6)
            
            Text(draft.content)
                .font(.custom("OpenSans-Regular", size: 14))
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
        .background(Color("AppBackgroundColor"))
    }
}
