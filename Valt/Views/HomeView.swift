import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct HomeView : View {
    @State private var isEditing = false
    @State private var draftText = ""
    
    var body: some View {
        VStack {
            HStack (spacing: 10){
                Spacer()
                
                // MARK: Favorite Icon
                Button(action: {
                    withAnimation {
                        // do something
                    }
                }) {
                    ZStack {
                        Ellipse()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("bubbleColor"))
                        
                        Image("Favorite-Inactive")
                            .frame(width: 38, height: 38)
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
                            .foregroundColor(Color("bubbleColor"))
                        
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
                            .foregroundColor(Color("bubbleColor"))
                        
                        Image("saveIcon")
                            .frame(width: 38, height: 38)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            VStack {
                    TextEditor(text: $draftText)
                        .font(.custom("OpenSans-Regular", size: 17))
                        .foregroundColor(Color("TextColor"))
                        .background(Color("AppBackgroundColor"))
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
        }
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
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("drafts").addDocument(data: draftData) { error in
            if let error = error {
                print("Error saving draft to Firestore: \(error.localizedDescription)")
            } else {
                print("✅ Draft saved successfully to Firestore!")
            }
        }
    }

}


#Preview {
    HomeView()
}
