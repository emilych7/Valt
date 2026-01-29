import SwiftUI

struct FullNotePreview: View {
    let draft: Draft
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 2) {
                Spacer()
                
                if draft.prompt != "" {
                    StatusIcon(name: "promptsIcon", size: 20)
                }

                if draft.isFavorited {
                    StatusIcon(name: "Favorite-Active", size: 20)
                }
                if draft.isPublished {
                    StatusIcon(name: "publishIcon", size: 20)
                }
                if draft.isHidden {
                    StatusIcon(name: "hideIcon", size: 20)
                }
            }
            .padding([.top, .trailing], 6)
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
