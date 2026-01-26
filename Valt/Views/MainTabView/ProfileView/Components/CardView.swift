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
                    .stroke(Color("TextColor").opacity(0.20), lineWidth: 1)
                    
                
                // Content Layer
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Spacer()
                        /*
                        if draft.prompt != nil {
                            StatusIcon(name: "promptsIcon")
                        }
                         */
                        if draft.isFavorited {
                            StatusIcon(name: "Favorite-Active")
                        }
                        if draft.isPublished {
                            StatusIcon(name: "publishIcon")
                        }
                        if draft.isHidden {
                            StatusIcon(name: "hideIcon")
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
            .onTapGesture { showFullNote = true }

            Text(draft.timestamp.formatted(
                .dateTime
                    .month(.defaultDigits)
                    .day(.defaultDigits)
                    .year(.twoDigits)
            ))
            .font(.custom("OpenSans-Regular", size: 11))
            .foregroundColor(Color("TextColor"))
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
