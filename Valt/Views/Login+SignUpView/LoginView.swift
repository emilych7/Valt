import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bannerManager: BannerManager
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: LoginViewModel.Field?

    var body: some View {
        ZStack {
            Color("AppBackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 52)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome Back")
                            .font(.custom("OpenSans-SemiBold", size: 30))
                            .foregroundColor(Color("TextColor"))
                        
                        Text("Sign in to your Valt account.")
                            .font(.custom("OpenSans-Regular", size: 15))
                            .foregroundColor(Color("TextColor").opacity(0.65))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    VStack(spacing: 10) {
                        AuthInputField(
                            title: "Username or Email",
                            placeholder: "Enter username or email",
                            text: $viewModel.identifier,
                            keyboardType: .emailAddress,
                            field: .identifier,
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
                        .submitLabel(.done)
                        
                        HStack {
                            Spacer()
                            Button {
                                focusedField = nil
                                viewModel.prepareForgotPassword()
                            } label: {
                                Text("Forgot Password?")
                                    .font(.custom("OpenSans-SemiBold", size: 13))
                                    .foregroundColor(Color("TextColor").opacity(0.75))
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 6)
                        }
                        .padding(.top, -2)
                        .padding(.bottom, 4)
                        
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
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        }
                        
                        AuthActionButton(
                            title: "Log In",
                            isLoading: viewModel.isLoading,
                            isDisabled: isFormInvalid
                        ) {
                            focusedField = nil
                            Task { await viewModel.performSignIn() }
                        }
                        .padding(.top, 4)
                        
                        Socials(title: "or continue with", isGoogleLoading: viewModel.isGoogleLoading) {
                            handleGoogleSignIn()
                        } onAppleTap: {
                            viewModel.performAppleSignIn()
                        }
                        .padding(.top, 4)
                        
                        signupRedirectSection
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 480)
                    
                    Spacer(minLength: 40)
                }
            }
            .onSubmit {
                if focusedField == .identifier {
                    focusedField = .password
                } else {
                    focusedField = nil
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .overlay(
            NavigationBar(onBackTap: {
                focusedField = nil
                authViewModel.navigate(to: .onboarding)
            }), alignment: .top
        )
        .onTapGesture {
            focusedField = nil
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $viewModel.showForgotPasswordSheet) {
            ForgotPasswordSheet(viewModel: viewModel)
        }
    }
    
    private func handleGoogleSignIn() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            Task {
                await viewModel.signInWithGoogle(presenting: rootVC)
            }
        }
    }
    
    private var isFormInvalid: Bool {
        viewModel.identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.password.isEmpty
    }
    
    private var signupRedirectSection: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundColor(Color("TextColor").opacity(0.75))
            
            Button {
                focusedField = nil
                authViewModel.navigate(to: .signup)
            } label: {
                Text("Sign up.")
                    .foregroundColor(.blue)
                    .font(.custom("OpenSans-SemiBold", size: 15))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16)
        .font(.custom("OpenSans-Regular", size: 15))
    }
}
