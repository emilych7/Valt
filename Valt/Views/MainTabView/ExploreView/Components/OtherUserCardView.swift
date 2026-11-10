import SwiftUI

struct OtherUserCardView: View {
    @EnvironmentObject private var viewModel: ExploreViewModel
    let draft: Draft
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardColor"))
                    
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
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onTap?()
            } label: {
                Label("Read Note", systemImage: "doc.text")
            }
            
            Button {
                UIPasteboard.general.string = "\(draft.title)\n\n\(draft.content)"
            } label: {
                Label("Copy Note", systemImage: "doc.on.doc")
            }
        } preview: {
            FullNotePreview(draft: draft)
        }
    }
}
