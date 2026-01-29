import SwiftUI

struct DraftToolBar: View {
    let draft: Draft
    @Binding var editedContent: String
    var isTextFieldFocused: FocusState<Bool>.Binding
    @ObservedObject var userViewModel: UserViewModel
    var onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button("Clear") {
                editedContent = ""
            }
            .foregroundColor(.red)
            
            Spacer()
            
            Button {
                isTextFieldFocused.wrappedValue = false
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .foregroundColor(Color("TextColor"))
            }
            
            Spacer()
            
            Button("Save") {
                Task {
                    if editedContent != draft.content {
                        await userViewModel.updateDraft(
                            draftID: draft.id,
                            updatedFields: ["content": editedContent, "timestamp": Date()]
                        )
                    } else {
                        onDismiss()
                    }
                }
            }
            .foregroundColor(Color("TextColor"))
        }
        .font(.custom("OpenSans-Regular", size: 16))
    }
}
