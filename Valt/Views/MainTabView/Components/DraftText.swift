import SwiftUI

struct DraftText: View {
    let draft: Draft
    @Binding var editedContent: String
    var isTextFieldFocused: FocusState<Bool>.Binding
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: draft.timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(formattedDate)
                    .font(.custom("OpenSans-SemiBold", size: 15))
                    .foregroundColor(Color("TextColor").opacity(0.7))
                Spacer()
            }
            if let promptText = draft.prompt {
                HStack {
                    Text(promptText)
                        .font(.custom("OpenSans-SemiBold", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.7))
                    Spacer()
                }
            }

            TextEditor(text: $editedContent)
                .focused(isTextFieldFocused)
                .font(.custom("OpenSans-Regular", size: 16))
                .foregroundColor(Color("TextColor"))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        .padding(.horizontal, 25)
        .background(Color("ValtRed"))
    }
}
