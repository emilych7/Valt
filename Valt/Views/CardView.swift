import SwiftUI

struct CardView: View {
    let title: String
    let content: String
    let timestamp: Date

    @State private var showFullNote: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 10) {
                /*
                Text(title)
                    .font(.custom("OpenSans-SemiBold", size: 14))
                    .foregroundColor(Color("TextColor"))
                    .lineLimit(2)
                 */
                Text(content)
                    .font(.custom("OpenSans-Regular", size: 10))
                    .foregroundColor(.black)
                    .lineLimit(1)
                Spacer()
            }
            // .frame(width: 150, height: 255)
        }
        .frame(width: 160, height: 245)
        .onTapGesture {
            showFullNote = true
        }
        .popover(isPresented: $showFullNote) {
            FullNoteView(lastSaved: timestamp, content: content)
                // .presentationCompactAdaptation(.fullScreenCover)
        }
    }
}
