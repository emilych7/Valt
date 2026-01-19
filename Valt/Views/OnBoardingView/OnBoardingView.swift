import SwiftUI

struct OnBoardingView: View {
    @EnvironmentObject private var onBoardingViewModel: OnBoardingViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        OffsetPageTabView(offset: $onBoardingViewModel.offset) {
            HStack(spacing: 0) {
                ForEach(boardingScreens) { screen in
                    OnBoardingPage(screen: screen)
                }
            }
        }
        .background(ellipseBackground, alignment: .leading)
        .background(Color("AppBackgroundColor"))
        .ignoresSafeArea(.keyboard)
        .overlay(bottomButtons, alignment: .bottom)
        .overlay(topNavigationBar, alignment: .top)
        .onAppear {
            onBoardingViewModel.resetOnboarding()
        }
    }

    private var ellipseBackground: some View {
        Ellipse()
            .fill(Color("TextFieldBackground"))
            .frame(width: onBoardingViewModel.getScreenBounds().width - 100, height: onBoardingViewModel.getScreenBounds().width - 10)
            .scaleEffect(2)
            .rotationEffect(.degrees(-30))
            .rotationEffect(.degrees(onBoardingViewModel.getRotation()))
            .offset(y: -onBoardingViewModel.getScreenBounds().width + 35)
            // .drawingGroup()
            .ignoresSafeArea(.keyboard)
    }

    private var bottomButtons: some View {
        VStack {
            HStack(spacing: 25) {
                Button {
                    Task {
                        authViewModel.navigate(to: .login)
                    }
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
                    Task {
                        authViewModel.navigate(to: .signup)
                    }
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
                withAnimation(.easeInOut(duration: 0.3)) {
                    onBoardingViewModel.offset = max(onBoardingViewModel.offset - onBoardingViewModel.getScreenBounds().width, 0)
                }
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
                withAnimation(.easeInOut(duration: 0.3)) {
                    let screenWidth = onBoardingViewModel.getScreenBounds().width
                    onBoardingViewModel.offset = min(onBoardingViewModel.offset + screenWidth, screenWidth * 3)
                }
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
                .offset(y: onBoardingViewModel.getScreenBounds().height < 750 ? -30 : -70)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack (spacing: 10) {
                    GlowingView()
                    
                    Text(screen.title)
                        .font(.custom("OpenSans-Bold", size: 28))
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                Text(screen.subtitle)
                    .font(.custom("OpenSans-SemiBold", size: 20))
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
