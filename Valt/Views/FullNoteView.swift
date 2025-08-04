import SwiftUI

struct FullNoteView: View {
    let lastSaved: Date
    let content: String
    @State private  var isFavorited = false
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = HomeViewModel()
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: lastSaved)
    }
    
    var body: some View {
        NavigationStack {
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
                            viewModel.showMoreOptions.toggle()
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
                    // .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $viewModel.showMoreOptions) {
                        MoreOptionsView(selection: $viewModel.selectedMoreOption) { option in
                            if option == .edit {
                                viewModel.showMoreOptions = false
                                                }
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
                
                
                VStack (alignment: .leading, spacing: 15)  {
                    HStack {
                        Text(formattedDate)
                            .font(.custom("OpenSans-SemiBold", size: 16))
                            .foregroundColor(Color("TextColor").opacity(0.7))
                        
                        Spacer()
                    }
                    
                    Text(content)
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


