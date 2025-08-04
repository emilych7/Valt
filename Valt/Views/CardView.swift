import SwiftUI

struct CardView: View {
    let id: String
    let title: String
    let content: String
    let timestamp: Date

    @State private var showFullNote: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("TextFieldBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("TextColor").opacity(0.2), lineWidth: 1) // border
                    )
                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
            
            VStack {
                HStack (spacing: 5) {
                    Spacer()
                    Image("promptsIcon")
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Image("Favorite-Active")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                VStack (alignment: .leading) {
                    Text(content)
                        .font(.custom("OpenSans-Regular", size: 6))
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .frame(width: 90, height: 110)
            }
            .padding(10)
        }
        .frame(width: 110, height: 155)
        .onTapGesture {
            showFullNote = true
        }
        .popover(isPresented: $showFullNote) {
            FullNoteView(lastSaved: timestamp, content: content)
                // .presentationCompactAdaptation(.fullScreenCover)
        }
    }
}



