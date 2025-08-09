import SwiftUI

struct CardView: View {
    let draftID: String
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var showFullNote: Bool = false

    private var draft: Draft? {
        userViewModel.drafts.first(where: { $0.id == draftID })
    }

    private var formattedDate: String {
        guard let timestamp = draft?.timestamp else { return "--/--/--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: timestamp)
    }

    var body: some View {
        VStack {
            if let draft = draft {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("TextFieldBackground"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("TextColor").opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)

                    VStack {
                        HStack(spacing: 5) {
                            Spacer()
                            if draft.isPrompted {
                                Image("promptsIcon")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                            }
                            if draft.isFavorited {
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
            } else {
                // Placeholder in case draft is missing
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 110, height: 155)
                    .overlay(Text("Loading...").font(.caption))
            }
        }
    }
}
