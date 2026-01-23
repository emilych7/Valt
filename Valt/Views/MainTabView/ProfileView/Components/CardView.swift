import SwiftUI

struct CardView: View {
    let draft: Draft
    @State private var showFullNote: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background Layer
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("TextFieldBackground"))
                    .stroke(Color("TextColor").opacity(0.50), lineWidth: 1)
                    
                
                // Content Layer
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Spacer()
                        if draft.isPrompted {
                            StatusIcon(name: "promptsIcon")
                        }
                        if draft.isFavorited {
                            StatusIcon(name: "Favorite-Active")
                        }
                    }
                    .padding([.top, .trailing], 6)

                    Text(draft.content)
                        .font(.custom("OpenSans-Regular", size: 6))
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding([.horizontal, .bottom], 8)
                }
                .padding(8)
            }
            .aspectRatio(0.7, contentMode: .fit)
            // .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
            .onTapGesture { showFullNote = true }

            Text(draft.timestamp.formatted(.dateTime.month().day().year(.defaultDigits)))
                .font(.custom("OpenSans-Regular", size: 8))
                .foregroundColor(Color("TextColor").opacity(0.6))
        }
        .fullScreenCover(isPresented: $showFullNote) {
            FullNoteView(draft: draft)
        }
    }
}

// Sub-component for card icons
struct StatusIcon: View {
    let name: String
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 10, height: 10)
    }
}
