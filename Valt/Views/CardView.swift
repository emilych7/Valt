import SwiftUI

struct CardView: View {
    let draft: Draft
    @State private var showFullNote: Bool = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: draft.timestamp)
    }

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("TextFieldBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("TextColor").opacity(0.2), lineWidth: 1) // border
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
                
                VStack {
                    HStack(spacing: 5) {
                        Spacer()
                        
                        if (draft.isPrompted) {
                            Image("promptsIcon")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                        
                        if (draft.isFavorited) {
                            Image("Favorite-Active")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(draft.content)
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
            .fullScreenCover(isPresented: $showFullNote) {
                FullNoteView(draft: draft)
            }
            HStack {
                Spacer()
                
                Text(formattedDate)
                    .foregroundColor(Color("TextColor").opacity(0.7))
                    .font(.custom("OpenSans-Regular", size: 12))
                
                Spacer()
            }
    }
    }
}
