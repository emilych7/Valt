import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct HomeView : View {
    @State private var isEditing = false
    @State private  var isFavorited = false
    @State private var draftText = ""
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject var bannerManager: BannerManager
    @State private var selectedMoreOption: MoreOption? = nil
    @State private var showMoreOptions: Bool = false

    var body: some View {
        VStack {
            HStack (spacing: 10){
                Spacer()
                
                // MARK: Favorite Icon
                Button(action: {
                    withAnimation {
                        isFavorited.toggle()
                    }
                }) {
                    ZStack {
                        Ellipse()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("BubbleColor"))
                        if isFavorited {
                            Image ("Favorite-Active")
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
                
                // MARK: Save Icon
                Button(action: {
                    withAnimation {
                        saveDraftToFirebase()
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
                
                // MARK: More Icon
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
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $showMoreOptions, content: {
                    MoreOptionsView(selection: $selectedMoreOption)
                        .presentationCompactAdaptation(.popover)
                })
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            ZStack(alignment: .topLeading) {
                if draftText.isEmpty && !isTextFieldFocused {
                    Text("Start your draft here")
                        .font(.custom("OpenSans-Regular", size: 17))
                        .foregroundColor(Color("TextColor").opacity(0.3))
                        .padding(EdgeInsets(top: 12, leading: 10, bottom: 0, trailing: 0))
                }

                TextEditor(text: $draftText)
                    .font(.custom("OpenSans-Regular", size: 17))
                    .foregroundColor(Color("TextColor"))
                    .scrollContentBackground(.hidden)
                    .focused($isTextFieldFocused)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AppBackgroundColor"))
            .cornerRadius(10)
            .padding(.bottom, 20)
            .padding(.horizontal, 25)
            .onTapGesture {
                isTextFieldFocused = true
            }


        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackgroundColor"))
    }
    private func saveDraftToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }

        let db = Firestore.firestore()
        let draftData: [String: Any] = [
            "userID": userID,                          // Must match rules
            "title": "Title",
            "content": draftText,
            "timestamp": FieldValue.serverTimestamp(),
            "isFavorited": isFavorited
        ]

        db.collection("drafts").addDocument(data: draftData) { error in
            if let error = error {
                print("Error saving draft to Firestore: \(error.localizedDescription)")
                bannerManager.show("Failed to save: \(error.localizedDescription)")
            } else {
                print("Successfully saved in Firestore.")
                draftText = ""
                isEditing = false
                bannerManager.show("Saved")
            }
        }
    }


}


#Preview {
    HomeView()
}
