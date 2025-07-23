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
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .sheet(isPresented: $showingSignUpSheet) {
            SignUpView()
        }
        .background(ellipseBackground, alignment: .leading)
        .background(dynamicScreenColor)
        .ignoresSafeArea(.container, edges: .all)
        .overlay(bottomButtons, alignment: .bottom)
        .overlay(topNavigationBar, alignment: .top)
    }

    // MARK: - Helper Functions

    func getRotation() -> Double {
        let progress = offset / (getScreenBounds().width * 4)
        return Double(progress) * 360
    }

    func getIndex() -> Int {
        let progress = (offset / getScreenBounds().width).rounded()
        return Int(progress)
    }

    // MARK: - Subviews / Computed Views

    private var ellipseBackground: some View {
        Ellipse()
            .fill(Color("AppBackgroundColor"))
            // .stroke(Color("BorderColor"), lineWidth: 2)
            .frame(width: getScreenBounds().width - 100, height: getScreenBounds().width - 10)
            .scaleEffect(2)
            .rotationEffect(.degrees(-30))
            .rotationEffect(.degrees(getRotation()))
            .offset(y: -getScreenBounds().width + 55)
    }

    private var dynamicScreenColor: some View {
        Color("screen\(getIndex() + 1)")
            .animation(.easeInOut, value: getIndex())
    }

    private var bottomButtons: some View {
        VStack {
            HStack(spacing: 25) {
                Button {
                    showingLoginSheet = true
                } label: {
                    Text("Login")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextColor"))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color("BubbleColor"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("BorderColor"), lineWidth: 1)
                        )
                }

                Button {
                    showingSignUpSheet = true
                } label: {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextColor"))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color("BubbleColor"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("BorderColor"), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .padding(.bottom, 10)
    }

    private var topNavigationBar: some View {
        HStack {
            Button("Back") {
                withAnimation {
                    offset = max(offset - getScreenBounds().width, 0)
                }
            }
            .fontWeight(.semibold)
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .tint(Color("BubbleColor"))
            .disabled(getIndex() == 0)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("BorderColor"), lineWidth: 1)
            )

            Spacer()

            HStack(spacing: 3) {
                ForEach(boardingScreens.indices, id: \.self) { index in
                    Circle()
                        .fill(Color("TextColor"))
                        .opacity(index == getIndex() ? 1 : 0.4)
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == getIndex() ? 1.2 : 0.75)
                        .animation(.easeInOut, value: getIndex())
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            Button("Next") {
                withAnimation {
                    offset = min(offset + getScreenBounds().width, getScreenBounds().width * 3)
                }
            }
            .fontWeight(.semibold)
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .tint(Color("BubbleColor"))
            .disabled(getIndex() == 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("BorderColor"), lineWidth: 1)
            )
        }
        .padding()
    }
}

struct OnBoardingPage: View {
    let screen: BoardingScreen

    var body: some View {
        VStack(spacing: 5) {
            Spacer()

            Image(screen.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: getScreenBounds().width - 100,
                       height: getScreenBounds().width - 100)
                .scaleEffect(getScreenBounds().height < 750 ? 0.9 : 1)
                .offset(y: getScreenBounds().height < 750 ? -100 : -120)

            VStack(alignment: .leading, spacing: 12) {
                Text(screen.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(Color("TextColor"))
                    .padding(.top, 20)

                Text(screen.description)
                    .foregroundColor(Color("TextColor"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(y: -50)

            Spacer()
        }
        .padding()
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
