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
                
                // MARK: More Icon
                Button(action: {
                    withAnimation {
                        // do something
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
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            VStack {
                if isEditing {
                    TextEditor(text: $draftText)
                        .font(.custom("OpenSans-Regular", size: 17))
                        .foregroundColor(Color("TextColor"))
                        .scrollContentBackground(.hidden)
                        .background(Color("AppBackgroundColor"))
                }
                else {
                    HStack (spacing: 10) {
                        GlowingView()
                        
                        Text("Start writing here")
                            .font(.custom("OpenSans-Regular", size: 17))
                            .foregroundColor(Color("TextColor"))
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onTapGesture {
                    isEditing.toggle()
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 25)
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
            "userID": userID,
            "title": "New Draft",
            "content": draftText,
            "timestamp": FieldValue.serverTimestamp(),
            "isFavorited": isFavorited
        ]

        db.collection("drafts").addDocument(data: draftData) { error in
            if let error = error {
                print("Error saving draft to Firestore: \(error.localizedDescription)")
            } else {
                print("Draft was successfully saved in Firestore.")
                draftText = ""
                isEditing = false
                bannerManager.show("Saved successfully!")
            }
        }
    }

}


#Preview {
    HomeView()
}
