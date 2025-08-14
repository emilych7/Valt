import SwiftUI

struct OnBoardingView: View {
    @State var offset: CGFloat = 0
    @State private var showingLoginSheet = false
    @State private var showingSignUpSheet = false

    var body: some View {
        OffsetPageTabView(offset: $offset) {
            HStack(spacing: 0) {
                ForEach(boardingScreens) { screen in
                    OnBoardingPage(screen: screen)
                }
            }
        }
        .fullScreenCover(isPresented: $showingLoginSheet) {
            LoginView()
        }
        /*
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
         */
        .sheet(isPresented: $showingSignUpSheet) {
            SignUpView()
        }
        .background(ellipseBackground, alignment: .leading)
        .background(Color("AppBackgroundColor"))
        .ignoresSafeArea(.container, edges: .all)
        .overlay(bottomButtons, alignment: .bottom)
        .overlay(topNavigationBar, alignment: .top)
    }

    // Helper Functions
    func getRotation() -> Double {
        let progress = offset / (getScreenBounds().width * 4)
        return Double(progress) * 360
    }

    func getIndex() -> Int {
        let progress = (offset / getScreenBounds().width).rounded()
        return Int(progress)
    }

    // Computed Views
    private var ellipseBackground: some View {
        Ellipse()
            .fill(Color("TextFieldBackground"))
            .frame(width: getScreenBounds().width - 100, height: getScreenBounds().width - 10)
            .scaleEffect(2)
            .rotationEffect(.degrees(-30))
            .rotationEffect(.degrees(getRotation()))
            .offset(y: -getScreenBounds().width + 35)
    }

    private var bottomButtons: some View {
        VStack {
            HStack(spacing: 25) {
                Button {
                    showingSignUpSheet = true
                } label: {
                    Text("Sign Up")
                        .font(.custom("OpenSans-Bold", size: 20))
                        .foregroundColor(Color("OnBoardingButtons"))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color("AppBackgroundColor"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("OnBoardingButtons"), lineWidth: 2)
                        )
                }
                
                Button {
                    showingLoginSheet = true
                } label: {
                    Text("Login")
                        .font(.custom("OpenSans-Bold", size: 20))
                        .foregroundColor(Color("OnBoardingButtonText"))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color("OnBoardingButtons"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("OnBoardingButtons"), lineWidth: 2)
                        )
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }

    private var topNavigationBar: some View {
        HStack {
            Button("Back") {
                offset = max(offset - getScreenBounds().width, 0)
            }
            .font(.custom("OpenSans-SemiBold", size: 13))
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .tint(Color("BubbleColor").opacity(0.50))
            .opacity(getIndex() == 0 ? 0 : 1)
            .disabled(getIndex() == 0)

            Spacer()

            HStack(spacing: 3) {
                ForEach(boardingScreens.indices, id: \.self) { index in
                    Circle()
                        .fill(Color("TextColor"))
                        .opacity(index == getIndex() ? 1 : 0.4)
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == getIndex() ? 1.2 : 0.75)
                        .animation(.smooth, value: getIndex())
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            Button("Next") {
                offset = min(offset + getScreenBounds().width, getScreenBounds().width * 3)
                
            }
            .font(.custom("OpenSans-SemiBold", size: 13))
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .opacity(getIndex() == 2 ? 0 : 1)
            .disabled(getIndex() == 2)
            .tint(Color("BubbleColor").opacity(0.50))
        }
        .padding(.horizontal, 25)
    }
}

struct OnBoardingPage: View {
    let screen: BoardingScreen

    var body: some View {
        VStack {
            Spacer()

            Image(screen.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 420, height: 240)
                // .scaleEffect(getScreenBounds().height < 750 ? 0.9 : 1)
                .offset(y: getScreenBounds().height < 750 ? -100 : -120)

            VStack(alignment: .leading, spacing: 10) {
                Text(screen.title)
                    .font(.custom("OpenSans-Bold", size: 30))
                    .foregroundColor(Color("TextColor"))
                
                Text(screen.subtitle)
                    .font(.custom("OpenSans-SemiBold", size: 22))
                    .foregroundColor(Color("TextColor"))

                Text(screen.description)
                    .font(.custom("OpenSans-Regular", size: 17))
                    .foregroundColor(Color("TextColor"))
                    .padding(.top, 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .offset(y: -30)

            Spacer()
        }
        .frame(width: getScreenBounds().width)
        .frame(maxHeight: .infinity)
    }
}

extension View {
    func getScreenBounds() -> CGRect {
        UIScreen.main.bounds
    }
}

struct OnBoarding_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OnBoardingView()
        }
    }
}
