import SwiftUI

struct OnBoardingView: View {
    @EnvironmentObject private var onBoardingViewModel: OnBoardingViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        ZStack {
            contentLayer
                .disabled(userViewModel.userLoadingState == .loading)
        }
    }

    private var contentLayer: some View {
        OffsetPageTabView(offset: $onBoardingViewModel.offset) {
            HStack(spacing: 0) {
                ForEach(boardingScreens) { screen in
                    OnBoardingPage(screen: screen)
                }
            }
        }
        .background(ellipseBackground, alignment: .center)
        .background(Color("AppBackgroundColor"))
        .ignoresSafeArea(.keyboard)
        .overlay(bottomButtons, alignment: .bottom)
        .overlay(topNavigationBar, alignment: .top)
        .onAppear {
            onBoardingViewModel.resetOnboarding()
        }
    }
    
    private var ellipseBackground: some View {
        let screenWidth = onBoardingViewModel.getScreenBounds().width
        let screenHeight = onBoardingViewModel.getScreenBounds().height
        let ellipseOffsetY = -screenHeight * (screenHeight < 750 ? 0.18 : 0.22)

        return Ellipse()
            .fill(Color("TextFieldBackground"))
            .frame(width: screenWidth - 20, height: screenWidth + 40)
            .scaleEffect(2.1)
            .rotationEffect(.degrees(-40))
            .rotationEffect(.degrees(onBoardingViewModel.getRotation()))
            .offset(y: ellipseOffsetY)
            .ignoresSafeArea(.keyboard)
    }

    private var bottomButtons: some View {
        VStack {
            HStack(spacing: 16) {
                Button {
                    Task {
                        authViewModel.navigate(to: .login)
                    }
                } label: {
                    Text("Login")
                        .font(.custom("OpenSans-Bold", size: 17))
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color("BubbleColor"))
                        )
                }
                .buttonStyle(TactileScaleButtonStyle())
                
                Button {
                    Task {
                        authViewModel.navigate(to: .signup)
                    }
                } label: {
                    Text("Sign Up")
                        .font(.custom("OpenSans-Bold", size: 17))
                        .foregroundColor(Color("TextColor"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color("AppBackgroundColor"))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color("BubbleColor"), lineWidth: 2)
                        )
                }
                .buttonStyle(TactileScaleButtonStyle())
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
    }

    private var topNavigationBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onBoardingViewModel.offset = max(onBoardingViewModel.offset - onBoardingViewModel.getScreenBounds().width, 0)
                }
            } label: {
                Text("Back")
                    .font(.custom("OpenSans-SemiBold", size: 13))
                    .foregroundColor(Color("TextColor"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color("BubbleColor"))
                    )
            }
            .buttonStyle(TactileScaleButtonStyle())
            .opacity(onBoardingViewModel.getIndex() == 0 ? 0 : 1)
            .disabled(onBoardingViewModel.getIndex() == 0)

            Spacer()

            HStack(spacing: 5) {
                ForEach(boardingScreens.indices, id: \.self) { index in
                    let isSelected = index == onBoardingViewModel.getIndex()
                    Circle()
                        .fill(Color("TextColor"))
                        .opacity(isSelected ? 1.0 : 0.35)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isSelected ? 1.25 : 0.85)
                        .animation(.smooth(duration: 0.25), value: onBoardingViewModel.getIndex())
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    let screenWidth = onBoardingViewModel.getScreenBounds().width
                    onBoardingViewModel.offset = min(onBoardingViewModel.offset + screenWidth, screenWidth * 3)
                }
            } label: {
                Text("Next")
                    .font(.custom("OpenSans-SemiBold", size: 13))
                    .foregroundColor(Color("TextColor"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color("BubbleColor"))
                    )
            }
            .buttonStyle(TactileScaleButtonStyle())
            .opacity(onBoardingViewModel.getIndex() == 2 ? 0 : 1)
            .disabled(onBoardingViewModel.getIndex() == 2)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
    }
}

struct TactileScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                }
            }
    }
}

struct OnBoardingPage: View {
    let screen: BoardingScreen
    @EnvironmentObject private var onBoardingViewModel: OnBoardingViewModel

    private var isCurrentPage: Bool {
        let index = onBoardingViewModel.getIndex()
        if screen.image == "screen1" || screen.image == "launchscreen" {
            return index == 0
        } else if screen.image == "screen2" {
            return index == 1
        } else if screen.image == "screen3" {
            return index == 2
        }
        return false
    }

    private var assetSize: CGFloat {
        onBoardingViewModel.getScreenBounds().height < 750 ? 170 : 205
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            imageSection
                .frame(width: onBoardingViewModel.getScreenBounds().width, height: assetSize)

            centeredTextSection
                .padding(.top, 50)

            Spacer(minLength: 35)
        }
        .padding(.top, 45)
        .padding(.bottom, 95)
        .frame(width: onBoardingViewModel.getScreenBounds().width)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var imageSection: some View {
        if screen.image == "screen1" || screen.image == "launchscreen" {
            ValtAnimatedLogo(size: assetSize, isSpinning: true, spinDuration: 15.0, isActive: isCurrentPage)
        } else if screen.image == "screen2" {
            ValtGlisteningNotes(size: assetSize, isActive: isCurrentPage)
        } else if screen.image == "screen3" {
            ValtThoughtCloud(size: assetSize, isActive: isCurrentPage)
        } else {
            Image(screen.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: assetSize, height: assetSize)
        }
    }

    private var centeredTextSection: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                if !screen.title.isEmpty {
                    Text(screen.title)
                        .font(.custom("OpenSans-Bold", size: 25))
                        .foregroundColor(Color("TextColor"))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !screen.subtitle.isEmpty {
                    Text(screen.subtitle)
                        .font(.custom(screen.title.isEmpty ? "OpenSans-Bold" : "OpenSans-SemiBold", size: screen.title.isEmpty ? 24 : 16))
                        .foregroundColor(screen.title.isEmpty ? Color("TextColor") : Color("TextColor").opacity(0.70))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(screen.description)
                .font(.custom("OpenSans-Regular", size: 15))
                .lineSpacing(4.5)
                .foregroundColor(Color("TextColor").opacity(0.85))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 15)
        }
        .padding(.horizontal, 32)
    }
}
