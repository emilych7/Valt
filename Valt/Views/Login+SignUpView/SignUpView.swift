import SwiftUI
import TipKit

@MainActor
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var viewModel: SignUpViewModel
    @FocusState private var focusedField: SignUpViewModel.Field?
    
    @State private var passwordTip = ValidationErrorTip(
        title: Text("Invalid Password"),
        message: nil
    )
    
    init(userViewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: SignUpViewModel(userViewModel: userViewModel))
    }
    
    var body: some View {
        ZStack {
            Color("AppBackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 52)
                    
                    Header(title: headerTitle)
                        .frame(maxWidth: 480, alignment: .leading)
                    
                    ZStack {
                        switch viewModel.currentStep {
                        case .accountDetails:
                            accountDetailsFields
                        case .chooseUsername:
                            UsernameSelectionView(viewModel: viewModel)
                        case .emailVerification:
                            EmailVerificationView(viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 480)
                    
                    Spacer(minLength: 40)
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
                handleBackTap()
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
        .onAppear {
            viewModel.syncAuthenticatedUser()
        }
    }
    
    private func handleBackTap() {
        switch viewModel.currentStep {
        case .accountDetails:
            authViewModel.navigate(to: .onboarding)
        case .chooseUsername:
            if viewModel.password.isEmpty {
                authViewModel.signOut()
                authViewModel.navigate(to: .onboarding)
            } else {
                authViewModel.signOut()
                viewModel.currentStep = .accountDetails
            }
        case .emailVerification:
            viewModel.continueLater()
        }
    }
    
    private var loginRedirectSection: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundColor(Color("TextColor").opacity(0.75))
            
            Button {
                focusedField = nil
                authViewModel.navigate(to: .login)
            } label: {
                Text("Log in.")
                    .foregroundColor(.blue)
                    .font(.custom("OpenSans-SemiBold", size: 15))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16)
        .font(.custom("OpenSans-Regular", size: 15))
    }
    
    private var accountDetailsFields: some View {
        VStack(spacing: 10) {
            AuthInputField(
                title: "Email",
                placeholder: "Enter email",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                field: .email,
                focusState: $focusedField,
                borderColor: viewModel.usernameBorderColor
            )
            .submitLabel(.next)
            
            AuthInputField(
                title: "Password",
                placeholder: "Enter password",
                text: $viewModel.password,
                isSecure: true,
                field: .password,
                focusState: $focusedField,
                borderColor: viewModel.passwordBorderColor
            )
            .submitLabel(.next)
            .popoverTip(passwordTip, arrowEdge: .bottom)
            .onChange(of: viewModel.passwordError) { _, newValue in
                if let errorMessage = newValue {
                    passwordTip.message = Text(errorMessage)
                    ValidationErrorTip.passwordHasError = true
                } else {
                    ValidationErrorTip.passwordHasError = false
                }
            }
            
            AuthInputField(
                title: "Confirm Password",
                placeholder: "Re-enter password",
                text: $viewModel.passwordConfirmation,
                isSecure: true,
                field: .passwordConfirmation,
                focusState: $focusedField,
                borderColor: viewModel.passwordBorderColor
            )
            .submitLabel(.done)
            
            if let errorMessage = viewModel.errorMessage {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.red)
                        .padding(.top, 2)
                    
                    Text(errorMessage)
                        .foregroundColor(Color("TextColor"))
                        .font(.custom("OpenSans-Regular", size: 14))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.red.opacity(0.10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.red.opacity(0.25), lineWidth: 1)
                        )
                )
                .padding(.vertical, 4)
            }
            
            AuthActionButton(
                title: "Sign Up",
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.canSubmitStep1
            ) {
                focusedField = nil
                Task {
                    await viewModel.validateAndStartSignup()
                }
            }
            .padding(.top, 4)
            
            Socials(title: "or continue with", isGoogleLoading: viewModel.isGoogleLoading) {
                Task {
                    await viewModel.signInWithGoogle()
                }
            } onAppleTap: {
                viewModel.performAppleSignIn()
            }
            .padding(.top, 4)
            
            loginRedirectSection
        }
    }

    private var headerTitle: String {
        switch viewModel.currentStep {
        case .accountDetails: return "Create an Account"
        case .chooseUsername: return "Choose a Username"
        case .emailVerification: return "Verify Your Email"
        }
    }
}

#Preview {
    SignUpView(userViewModel: UserViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(TabManager())
}
