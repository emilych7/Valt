import SwiftUI

struct CardView: View {
    @ObservedObject var userViewModel: UserViewModel
    let draft: Draft
    @Binding var selectedDraft: Draft?
    @Binding var showNote: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background Layer
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardColor"))
                
                // Content Layer
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Spacer()
                        
                        if draft.isPrompted {
                            StatusIcon(name: "promptsIcon", size: 10)
                        }
        
                        if draft.isFavorited {
                            StatusIcon(name: "Favorite-Active", size: 10)
                        }
                        if draft.isPublished {
                            StatusIcon(name: "publishIcon", size: 10)
                        }
                        if draft.isHidden {
                            StatusIcon(name: "hideIcon", size: 10)
                        }
                    }
                    .padding([.top, .trailing], 6)
                    
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
            .onTapGesture {
                selectedDraft = draft
                showNote = true
            }
            .contextMenu {
                Button {
                    withAnimation(.smooth()) { selectedDraft = draft }
                    showNote = true
                } label: {
                    Label("Open Full Note", image: "editIcon")
                }
                
                Button(role: .destructive) {
                    Task {
                        await userViewModel.deleteDraft(draftID: draft.id)
                    }
                } label: {
                    Label("Delete", image: "trashIcon")
                }
            } preview: {
                FullNotePreview(draft: draft)
            }

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

struct StatusIcon: View {
    let name: String
    let size: CGFloat
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
