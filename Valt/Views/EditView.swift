import SwiftUI

struct EditView : View {
    let id: String
    let content: String
    let time: String
    @State var isFavorited: Bool = false
    private let repository: DraftRepositoryProtocol
    
    /*
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: lastSaved)
    }
     */
    
    var body: some View {
        VStack {
            HStack (spacing: 10) {
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
                
                // Exit Button
                Button(action: {
                    withAnimation {
                        // try await repository.deleteDraft(draftID: id)
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
            
            VStack (alignment: .leading, spacing: 15)  {
                HStack {
                    Text("Month Day Year") // substitute with formatted date
                        .font(.custom("OpenSans-SemiBold", size: 16))
                        .foregroundColor(Color("TextColor").opacity(0.7))
                    
                    Spacer()
                }
                
                Text("Test") // substitute with draft content
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



