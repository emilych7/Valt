import SwiftUI

struct OtherUserCardView: View {
    @EnvironmentObject private var viewModel: ExploreViewModel
    let draft: Draft

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background Layer
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardColor"))
                
                // Content Layer
                VStack(spacing: 0) {
                    Text(draft.content)
                        .font(.custom("OpenSans-Regular", size: 8))
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding([.horizontal, .bottom], 6)
                }
                .padding(4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12))
            .aspectRatio(0.7, contentMode: .fit)
//            .onTapGesture {
//                selectedDraft = draft
//                showNote = true
//            }
            
//            .contextMenu {
//                Button {
////                    withAnimation(.smooth()) { selectedDraft = draft }
////                    showNote = true
//                } label: {
//                    Label("Open Full Note", image: "editIcon")
//                }
//            } preview: {
//                // FullNotePreview(draft: draft)
//            }

            Text(draft.timestamp.formatted(
                .dateTime
                .month(.defaultDigits)
                .day(.defaultDigits)
                .year(.twoDigits)
            ))
            .font(.custom("OpenSans-Regular", size: 13))
            .foregroundColor(Color("TextColor").opacity(0.7))
        }
    }
}
