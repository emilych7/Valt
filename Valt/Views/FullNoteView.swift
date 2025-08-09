import SwiftUI

struct FullNoteView: View {
    let draft: Draft
    let updatedDate = Date()
    
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @Environment(\.dismiss) var dismiss

    @State private var isFavorited = false
    @State private var showMoreOptions = false
    @State private var selectedMoreOption: MoreOption? = nil
    @State private var showDeleteConfirmation = false
    @State private var editedContent: String

    init(draft: Draft) {
        self.draft = draft
        _editedContent = State(initialValue: draft.content)
    }
    

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: draft.timestamp)
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 10) {
                    Spacer()

                    // Favorite Button
                    Button(action: {
                        withAnimation {
                            isFavorited.toggle()
                        }
                        Task {
                            await userViewModel.updateDraft(draftID: draft.id, updatedFields: ["isFavorited": isFavorited])
                            print("Favorited draft in Firebase")
                        }
                        
                    }) {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("BubbleColor"))
                            Image(draft.isFavorited || isFavorited ? "Favorite-Active" : "Favorite-Inactive")
                                .frame(width: 38, height: 38)
                                .opacity(draft.isFavorited || isFavorited ? 1 : 0.5)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Save Button
                    Button(action: {
                        Task {
                            if (editedContent != draft.content) {
                                await userViewModel.updateDraft(draftID: draft.id, updatedFields: ["content": editedContent, "timestamp": updatedDate])
                                withAnimation {
                                    dismiss()
                                }
                                bannerManager.show("Saved")
                            } else {
                                print("No changes to save. Closing draft now.")
                                dismiss()
                            }
                        }
                    }) {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("BubbleColor"))
                            Image("saveIcon")
                                .frame(width: 38, height: 38)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    // More Button
                    Button(action: {
                        withAnimation { showMoreOptions.toggle() }
                    }) {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("BubbleColor"))
                            Image("moreIcon")
                                .frame(width: 38, height: 38)
                        }
                    }
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

                    // Exit button
                    Button(action: {
                        withAnimation { dismiss() }
                    }) {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                            Image("exitIcon")
                                .frame(width: 38, height: 38)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text(formattedDate)
                            .font(.custom("OpenSans-SemiBold", size: 16))
                            .foregroundColor(Color("TextColor").opacity(0.7))
                        Spacer()
                    }

                    TextEditor(text: $editedContent)
                        .focused($isTextFieldFocused)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor"))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                isTextFieldFocused = true
            }
            .alert("Delete This Draft?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        await userViewModel.deleteDraft(draftID: draft.id)
                        dismiss()
                        bannerManager.show("Deleted draft", backgroundColor: .red, icon: "trash")
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this draft? This action cannot be undone.")
            }
        }
    }
}
