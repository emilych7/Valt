import SwiftUI

struct OnBoardingView: View {
    @EnvironmentObject private var onBoardingViewModel: OnBoardingViewModel
    
    @State private var showingLoginSheet = false
    @State private var showingSignUpSheet = false

    var body: some View {
        OffsetPageTabView(offset: $onBoardingViewModel.offset) {
            HStack(spacing: 0) {
                ForEach(boardingScreens) { screen in
                    OnBoardingPage(screen: screen)
                }
            }
        }
        .fullScreenCover(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .fullScreenCover(isPresented: $showingSignUpSheet) {
            SignUpView()
        }
        .background(ellipseBackground, alignment: .leading)
        .background(Color("AppBackgroundColor"))
        .ignoresSafeArea(.container, edges: .all)
        .overlay(bottomButtons, alignment: .bottom)
        .overlay(topNavigationBar, alignment: .top)
    }

    

    // Computed Views
    private var ellipseBackground: some View {
        Ellipse()
            .fill(Color("TextFieldBackground"))
            .frame(width: onBoardingViewModel.getScreenBounds().width - 100, height: onBoardingViewModel.getScreenBounds().width - 10)
            .scaleEffect(2)
            .rotationEffect(.degrees(-30))
            .rotationEffect(.degrees(onBoardingViewModel.getRotation()))
            .offset(y: -onBoardingViewModel.getScreenBounds().width + 35)
    }

    private var bottomButtons: some View {
        VStack {
            HStack(spacing: 25) {
                Button {
                    showingLoginSheet = true
                } label: {
                    Text("Login")
                        .font(.custom("OpenSans-Bold", size: 20))
                        .foregroundColor(Color("ReverseTextColor"))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color("TextColor"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("TextColor"), lineWidth: 2)
                        )
                }
                
                Button {
                    showingSignUpSheet = true
                } label: {
                    Text("Sign Up")
                        .font(.custom("OpenSans-Bold", size: 20))
                        .foregroundColor(Color("TextColor"))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color("AppBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("TextColor"), lineWidth: 2)
                        )
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 20)
    }

    private var topNavigationBar: some View {
        HStack {
            Button("Back") {
                onBoardingViewModel.offset = max(onBoardingViewModel.offset - onBoardingViewModel.getScreenBounds().width, 0)
            }
            .font(.custom("OpenSans-SemiBold", size: 13))
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .tint(Color("BubbleColor").opacity(0.50))
            .opacity(onBoardingViewModel.getIndex() == 0 ? 0 : 1)
            .disabled(onBoardingViewModel.getIndex() == 0)

            Spacer()

            HStack(spacing: 3) {
                ForEach(boardingScreens.indices, id: \.self) { index in
                    Circle()
                        .fill(Color("TextColor"))
                        .opacity(index == onBoardingViewModel.getIndex() ? 1 : 0.4)
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == onBoardingViewModel.getIndex() ? 1.2 : 0.75)
                        .animation(.smooth, value: onBoardingViewModel.getIndex())
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            Button("Next") {
                onBoardingViewModel.offset = min(onBoardingViewModel.offset + onBoardingViewModel.getScreenBounds().width, onBoardingViewModel.getScreenBounds().width * 3)
                
            }
            .font(.custom("OpenSans-SemiBold", size: 13))
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .opacity(onBoardingViewModel.getIndex() == 2 ? 0 : 1)
            .disabled(onBoardingViewModel.getIndex() == 2)
            .tint(Color("BubbleColor").opacity(0.50))
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 10)
    }
}

struct OnBoardingPage: View {
    let screen: BoardingScreen
    @EnvironmentObject private var onBoardingViewModel: OnBoardingViewModel

    var body: some View {
        VStack {
            Spacer()

            Image(screen.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 220)
                .offset(y: onBoardingViewModel.getScreenBounds().height < 750 ? -40 : -90)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack (spacing: 10) {
                    GlowingView()
                    
                    Text(screen.title)
                        .font(.custom("OpenSans-Bold", size: 30))
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                Text(screen.subtitle)
                    .font(.custom("OpenSans-SemiBold", size: 21))
                    .foregroundColor(Color("TextColor"))

                Text(screen.description)
                    .font(.custom("OpenSans-Regular", size: 17))
                    .foregroundColor(Color("TextColor"))
                    .padding(.top, 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            // .offset(y: -30)
            
            Spacer()
        }
        .frame(width: onBoardingViewModel.getScreenBounds().width)
        .frame(maxHeight: .infinity)
    }
}

struct OnBoarding_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OnBoardingView()
        }
    }
}
