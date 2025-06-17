import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Binding var showSettingsOverlayBinding: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var userID: String? = Auth.auth().currentUser?.uid
    @State private var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    @State private var drafts: [Draft] = []
    @State private var draftCount: Int = 0
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack (spacing: 15) {
                        GlowingView()
                        
                        Text("Welcome, username") // MARK: Add username later
                            .font(.custom("OpenSans-SemiBold", size: 24))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showSettingsOverlayBinding.toggle()
                        }
                    }) {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("bubbleColor"))
                            
                            Image("settingsIcon")
                                .frame(width: 38, height: 38)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.leading, 25)
                .padding(.top, 20)
                .padding(.trailing, 25)
                
                HStack {
                    Ellipse()
                        .frame(width: 115, height: 115)
                        .foregroundColor(Color("bubbleColor"))
                    
                    VStack (alignment: .leading, spacing: 5) {
                        Text("@username") // MARK: Add username
                            .font(.custom("OpenSans-Regular", size: 23))
                        
                        Text("\(draftCount) drafts") // MARK: Add total note count
                            .font(.custom("OpenSans-Bold", size: 16))
                        
                        Text("# published") // MARK: Add total published count
                            .font(.custom("OpenSans-Regular", size: 16))
                    }
                    .padding(.horizontal, 5)
                    .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                }
                .padding(.leading, 35)
                .padding(.trailing, 20)
                
                HStack {
                    Text("Archives")
                        .font(.custom("OpenSans-SemiBold", size: 20))
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.leading, 25)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(drafts) { draft in
                            CardView(title: draft.title, content: draft.content)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            loadDrafts()
            fetchDraftCount()
        }
    }
    func loadDrafts() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        fetchDrafts(for: userID) { drafts in
            self.drafts = drafts
        }
    }
    

    private func fetchDraftCount() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("drafts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching drafts: \(error)")
                    draftCount = 0
                    return
                }
                draftCount = snapshot?.documents.count ?? 0
            }
    }

}


