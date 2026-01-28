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
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("TextColor").opacity(0.2), lineWidth: 0.5)
                            .shadow(color: .black, radius: 5, x: 0, y: 0)
                    )
                // Content Layer
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Spacer()
                        /*
                        if draft.prompt = nil {
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
                        .font(.custom("OpenSans-Regular", size: 5))
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding([.horizontal, .bottom], 6)
                }
                .padding(4)
            }
            .aspectRatio(0.7, contentMode: .fit)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    selectedDraft = draft
                }
            }
            .contextMenu {
                Button {
                    withAnimation(.spring()) { selectedDraft = draft }
                } label: {
                    Label("Open Full Note", systemImage: "arrow.up.forward.app")
                }
                
                Button(role: .destructive) {
                    Task {
                        await userViewModel.deleteDraft(draftID: draft.id)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
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
