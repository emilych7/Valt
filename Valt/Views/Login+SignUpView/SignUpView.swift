import SwiftUI

@MainActor
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var viewModel = SignUpViewModel()
    @FocusState private var focusedField: SignUpViewModel.Field?
    
    var body: some View {
        ZStack {
            Color("AppBackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 0) {
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.10)
                    
                    Header(title: headerTitle)
                    
                    VStack(spacing: 5) {
                        switch viewModel.currentStep {
                        case .accountDetails:
                            accountDetailsFields
                        case .emailVerification:
                            EmailVerificationView(viewModel: viewModel)
                        case .chooseUsername:
                            UsernameSelectionView(viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 50)
                }
            }
            .onSubmit {
                switch focusedField {
                case .email: focusedField = .password
                case .password: focusedField = .passwordConfirmation
                case .passwordConfirmation: focusedField = nil
                case .username: focusedField = nil
                default: focusedField = nil
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .overlay(
            NavigationBar(onBackTap: {
                focusedField = nil
                
                if viewModel.currentStep == .emailVerification {
                    viewModel.currentStep = .accountDetails
                } else {
                    Task {
                        authViewModel.navigate(to: .onboarding)
                    }
                }
            }), alignment: .top
        )
        .onTapGesture {
            focusedField = nil
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: viewModel.isSignupComplete) { oldValue, newValue in
            if newValue {
                authViewModel.finalizeAuthTransition()
            }
        }
    }
    
    private var loginRedirectSection: some View {
        HStack (spacing: 4) {
            Text("Already have an account?")
                .foregroundColor(Color("TextColor"))
            
            Button {
                focusedField = nil
                authViewModel.navigate(to: .login)
            } label: {
                Text("Log in.")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 15)
        .font(.custom("OpenSans-Regular", size: 17))
    }
    
    private var accountDetailsFields: some View {
        VStack(spacing: 5) {
            AuthInputField(title: "Email", placeholder: "Email", text: $viewModel.email, keyboardType: .emailAddress, field: .email, focusState: $focusedField)
                .submitLabel(.next)
            
            AuthInputField(title: "Password", placeholder: "Password", text: $viewModel.password, isSecure: true, field: .password, focusState: $focusedField)
                .submitLabel(.next)
            
            AuthInputField(title: "Confirm Password", placeholder: "Re-Enter Password", text: $viewModel.passwordConfirmation, isSecure: true, field: .passwordConfirmation, focusState: $focusedField)
                .submitLabel(.done)
            
            AuthActionButton(
                title: "Sign Up",
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.canSubmitStep1
            ) {
                focusedField = nil
                Task { await viewModel.validateAndStartSignup() }
            }
            
            Socials(title: "or sign up using", isGoogleLoading: viewModel.isGoogleLoading) {
                Task {
                    print("Google Sign Up button tapped")
                    await viewModel.signInWithGoogle()
                }
            } onAppleTap: {
                print("Apple Sign Up button tapped")
            }
            
            loginRedirectSection
        }
    }

    private var headerTitle: String {
        switch viewModel.currentStep {
        case .accountDetails: return "Create an Account"
        case .emailVerification: return "Verify Your Email"
        case .chooseUsername: return "Choose a Username"
        }
    }
}
