import SwiftUI

struct FullNoteView: View {
    let draft: Draft
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    
    @State private var isFavorited = false
    @Environment(\.dismiss) var dismiss
    
    @State private var showMoreOptions = false
    @State private var selectedMoreOption: MoreOption? = nil
    
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
                    }) {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("BubbleColor"))
                            if (draft.isFavorited || isFavorited) {
                                Image("Favorite-Active")
                                    .frame(width: 38, height: 38)
                            }
                            else {
                                Image("Favorite-Inactive")
                                    .frame(width: 38, height: 38)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Save Button
                    Button(action: {
                        withAnimation {
                            // saveDraftToFirebase()
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
                        withAnimation {
                            showMoreOptions.toggle()
                        }
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
                                print("Publish option selected.")
                            case .hide:
                                print("Hide option selected.")
                            case .delete:
                                Task {
                                    await userViewModel.deleteDraft(draftID: draft.id)
                                    withAnimation {
                                        dismiss()
                                    }
                                    bannerManager.show("Deleted draft")
                                }
                            }
                            selectedMoreOption = nil
                            showMoreOptions = false
                        }
                        .presentationCompactAdaptation(.popover)
                    }
                    
                    // Exit button
                    Button(action: {
                        withAnimation {
                            dismiss()
                        }
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
                    
                    Text(draft.content)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(Color("TextColor"))
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
