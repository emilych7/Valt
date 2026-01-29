import SwiftUI

struct DraftIcons: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var editedContent: String
    @Binding var showDeleteConfirmation: Bool
    @State private var showMoreOptions = false
    @State private var selectedMoreOption: MoreOption? = nil
    @State private var localIsFavorited: Bool
    
    let draft: Draft
    let isDirty: Bool
    
    var onDismiss: () -> Void
    
    init(userViewModel: UserViewModel, editedContent: Binding<String>, showDeleteConfirmation: Binding<Bool>, draft: Draft, isDirty: Bool, onDismiss: @escaping () -> Void) {
        self.userViewModel = userViewModel
        self._editedContent = editedContent
        self._showDeleteConfirmation = showDeleteConfirmation
        self.draft = draft
        self.isDirty = isDirty
        self.onDismiss = onDismiss
        self._localIsFavorited = State(initialValue: draft.isFavorited)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Spacer()

            // Favorite
            Button(action: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                    localIsFavorited.toggle()
                }
                Task {
                    await userViewModel.updateDraft(
                        draftID: draft.id,
                        updatedFields: ["isFavorited": localIsFavorited]
                    )
                }
            }) {
                ZStack {
                    Ellipse().frame(width: 40, height: 40)
                        .foregroundColor(Color("BubbleColor"))
                    Image(localIsFavorited ? "Favorite-Active" : "Favorite-Inactive")
                        .frame(width: 38, height: 38)
                        .opacity(localIsFavorited ? 1 : 0.5)
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Save
            if isDirty {
                Button(action: {
                    Task {
                        if editedContent != draft.content {
                            await userViewModel.updateDraft(
                                draftID: draft.id,
                                updatedFields: ["content": editedContent, "timestamp": Date()]
                            )
                            withAnimation { onDismiss() }
                        } else {
                            onDismiss()
                        }
                    }
                }) {
                    ZStack {
                        Ellipse().frame(width: 40, height: 40)
                            .foregroundColor(Color("BubbleColor"))
                        Image("saveIcon").frame(width: 38, height: 38)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .trailing).combined(with: .opacity)
                ))
                .contentTransition(.opacity)
            }

            // More
            Button(action: { withAnimation { showMoreOptions.toggle() } }) {
                ZStack {
                    Ellipse().frame(width: 40, height: 40)
                        .foregroundColor(Color("BubbleColor"))
                    Image("moreIcon").frame(width: 38, height: 38)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $showMoreOptions) {
                MoreOptionsView(selection: $selectedMoreOption) { option in
                    switch option {
                        case .publish:
                            Task {
                                await userViewModel.updateDraft(draftID: draft.id, updatedFields: ["isPublished": true])
                                onDismiss()
                            }
                        case .hide:
                            Task {
                                await userViewModel.updateDraft(draftID: draft.id, updatedFields: ["isHidden": true])
                                onDismiss()
                            }
                        case .delete:
                            showMoreOptions = false
                            showDeleteConfirmation = true
                    }
                    selectedMoreOption = nil
                }
                .presentationCompactAdaptation(.popover)
            }

            // Exit
            Button(action: { withAnimation { onDismiss() } }) {
                ZStack {
                    Ellipse().frame(width: 40, height: 40)
                        .foregroundColor(.red)
                    Image("exitIcon").frame(width: 38, height: 38)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: isDirty)
    }
}
