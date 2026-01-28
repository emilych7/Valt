import SwiftUI

struct CardView: View {
    @ObservedObject var userViewModel: UserViewModel
    let draft: Draft
    @Binding var selectedDraft: Draft?

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background Layer
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("CardColor"))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color("TextColor").opacity(0.2), lineWidth: 0.5)
//                            .shadow(color: .black, radius: 5, x: 0, y: 0)
//                    )
                // Content Layer
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Spacer()
                        
                        if draft.prompt != "" {
                            StatusIcon(name: "promptsIcon")
                        }
        
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
                        .font(.custom("OpenSans-Regular", size: 5))
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
                withAnimation(.smooth()) {
                    selectedDraft = draft
                }
            }
            .contextMenu {
                Button {
                    withAnimation(.smooth()) { selectedDraft = draft }
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
            .font(.custom("OpenSans-Regular", size: 11))
            .foregroundColor(Color("TextColor").opacity(0.7))
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
