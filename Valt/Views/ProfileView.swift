import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import FirebaseCore
import UIKit

extension UIImage {
    func resized(to newSize: CGSize, quality: CGFloat = 0.8) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

struct ProfileView: View {
    @Binding var showSettingsOverlayBinding: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var userID: String? = Auth.auth().currentUser?.uid
    @State private var isUserLoggedIn: Bool = Auth.auth().currentUser != nil
    @State private var drafts: [Draft] = []
    @State private var draftCount: Int = 0
    
    @State private var selectedFilter: Filter? = nil
    @State private var showFilterOptions: Bool = false
    
    
    @State private var showNote: Bool = false
    var filteredDrafts: [Draft] {
        guard let selectedFilter = selectedFilter else {
            return drafts
        }

        switch selectedFilter {
        case .mostRecent:
            return drafts.sorted { $0.timestamp > $1.timestamp }
        case .favorites:
            return drafts.filter { $0.isFavorited }
        case .hidden:
            return drafts.filter { $0.isHidden }
        }
    }

    
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack (spacing: 15) {
                        GlowingView()
                        
                        Text("Welcome, username")
                            .font(.custom("OpenSans-Regular", size: 24))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                            showSettingsOverlayBinding.toggle()
                        
                    }) {
                        ZStack {
                            Ellipse()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color("BubbleColor"))
                            
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
                        .foregroundColor(Color("BubbleColor"))
                    
                    VStack (alignment: .leading, spacing: 5) {
                        Text("@username") // MARK: Add username
                            .font(.custom("OpenSans-SemiBold", size: 23))
                        
                        Text("\(draftCount) notes") // MARK: Add total note count
                            .font(.custom("OpenSans-Regular", size: 16))
                        
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
                        .font(.custom("OpenSans-SemiBold", size: 18))
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 80, height: 30)
                            .cornerRadius(10)
                            .foregroundColor(Color("BubbleColor"))
                        Button(action: {
                            showFilterOptions.toggle()
                        }
                        ) {
                            HStack (spacing: 5) {
                                Text("Filter")
                                    .font(.custom("OpenSans-Regular", size: 14))
                                    .foregroundColor(Color("TextColor"))
                                Image("filterIcon")
                                    .frame(width: 15, height: 15)
                            }
                        }
                        
                    }
                    .popover(isPresented: $showFilterOptions, content: {
                        FilterOptionsView(selection: $selectedFilter)
                            .presentationCompactAdaptation(.popover)
                    })
                }
                .padding(.top, 10)
                .padding(.horizontal, 25)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(filteredDrafts) { draft in
                            CardView(title: draft.title, content: draft.content, timestamp: draft.timestamp)
                        }
                    }
                    .padding(.horizontal, 25)
                }
                .scrollIndicators(.hidden)
                
                Spacer()
            }
            .background(Color("AppBackgroundColor"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .onAppear {
            loadDrafts()
            fetchDraftCount()
        }
        .task {

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


