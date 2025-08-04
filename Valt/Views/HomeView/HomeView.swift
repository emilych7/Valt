import SwiftUI

struct HomeView : View {
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        VStack {
            HStack (spacing: 10){
                Spacer()
                
                // Favorite Button
                Button(action: {
                    withAnimation {
                        viewModel.isFavorited.toggle()
                    }
                }) {
                    ZStack {
                        Ellipse()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("BubbleColor"))
                        if viewModel.isFavorited {
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
                        viewModel.saveDraftToFirebase()
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
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $viewModel.showMoreOptions, content: {
                    MoreOptionsView(selection: $viewModel.selectedMoreOption)
                        .presentationCompactAdaptation(.popover)
                })
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            ZStack(alignment: .topLeading) {
                if viewModel.draftText.isEmpty && !isTextFieldFocused {
                    Text("Start your draft here")
                        .font(.custom("OpenSans-Regular", size: 17))
                        .foregroundColor(Color("TextColor").opacity(0.3))
                        .padding(EdgeInsets(top: 12, leading: 10, bottom: 0, trailing: 0))
                }

                TextEditor(text: $viewModel.draftText)
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
}

#Preview {
    HomeView()
}
