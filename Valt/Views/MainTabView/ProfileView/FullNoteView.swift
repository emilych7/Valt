import SwiftUI

struct FullNoteView: View {
    let draft: Draft
    let updatedDate = Date()
    
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @Environment(\.dismiss) var dismiss

    @State private var isFavorited = false
    @State private var isEditingContent = false
    @State private var showMoreOptions = false
    @State private var selectedMoreOption: MoreOption? = nil
    @State private var showDeleteConfirmation = false
    @State private var editedContent: String
    
    
    init(draft: Draft) {
        self.draft = draft
        _editedContent = State(initialValue: draft.content)
    }
    
    private var isDirty: Bool {
        editedContent != draft.content
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: draft.timestamp)
    }

    var body: some View {
            VStack {
                HStack(spacing: 10) {
                    Spacer()

                    // Favorite
                    Button(action: {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                            isFavorited.toggle()
                        }
                        Task {
                            await userViewModel.updateDraft(
                                draftID: draft.id,
                                updatedFields: ["isFavorited": isFavorited]
                            )
                        }
                    }) {
                        ZStack {
                            Ellipse().frame(width: 40, height: 40)
                                .foregroundColor(Color("BubbleColor"))
                            Image(draft.isFavorited || isFavorited ? "Favorite-Active" : "Favorite-Inactive")
                                .frame(width: 38, height: 38)
                                .opacity(draft.isFavorited || isFavorited ? 1 : 0.5)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Save button shows only when the edited content is different than the original
                    if isDirty {
                        Button(action: {
                            Task {
                                if editedContent != draft.content {
                                    await userViewModel.updateDraft(
                                        draftID: draft.id,
                                        updatedFields: ["content": editedContent, "timestamp": Date()]
                                    )
                                    withAnimation { dismiss() }
                                    bannerManager.show("Saved")
                                } else {
                                    dismiss()
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
                                        dismiss()
                                    }
                                case .hide:
                                    Task {
                                        await userViewModel.updateDraft(draftID: draft.id, updatedFields: ["isHidden": true])
                                        dismiss()
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
                    Button(action: { withAnimation { dismiss() } }) {
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
                                .foregroundColor(Color("TextColor").opacity(0.6))
                            Spacer()
                        }
                    }
        
                    TextEditor(text: $editedContent)
                        .focused($isTextFieldFocused)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor"))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .padding(.horizontal, 25)

                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button("Clear") {
                            editedContent = ""
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button {
                            isTextFieldFocused = false
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
                                    withAnimation { dismiss() }
                                    bannerManager.show("Saved")
                                } else {
                                    dismiss()
                                }
                            }
                        }
                        .foregroundColor(Color("TextColor"))
                    }
                    .font(.custom("OpenSans-Regular", size: 16))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert("Delete Draft?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        await userViewModel.deleteDraft(draftID: draft.id)
                        dismiss()
                        bannerManager.show("Draft deleted", backgroundColor: Color("ValtRed"), icon: "trash")
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete this draft?")
            }
    }
    
    func dismissKeyboardSmoothly() {
        DispatchQueue.main.async {
            isTextFieldFocused = false
        }
    }
}
