import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bannerManager: BannerManager
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?
        
    enum Field { case identifier, password }

    var body: some View {
        ZStack {
            Color("AppBackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // 10% of screen
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.10)
                    
                    HStack {
                        Text("Welcome Back")
                            .font(.custom("OpenSans-SemiBold", size: 30))
                            .foregroundColor(Color("TextColor"))
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    
                    VStack(spacing: 5) {
                        AuthInputField(
                            title: "Username or Email",
                            placeholder: "Username or Email",
                            text: $viewModel.identifier,
                            field: .identifier,
                            focusState: $focusedField
                        )
                        .padding(.top, 20)
                        
                        AuthInputField(
                            title: "Password",
                            placeholder: "Password",
                            text: $viewModel.password,
                            isSecure: true,
                            field: .password,
                            focusState: $focusedField
                        )
                        
                        AuthActionButton(
                            title: "Log In",
                            isLoading: viewModel.isLoading,
                            isDisabled: isFormInvalid
                        ) {
                            focusedField = nil
                            Task { await viewModel.performSignIn() }
                        }
                        
                        Socials(title: "or login using", isGoogleLoading: viewModel.isGoogleLoading) {
                            viewModel.isGoogleLoading = true
                            print("Google Login button tapped")
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                Task {
                                    await viewModel.signInWithGoogle(presenting: rootVC)
                                }
                            }
                        } onAppleTap: {
                            print("Apple Login button tapped")
                        }
                        
                        signupRedirectSection
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.custom("OpenSans-Regular", size: 14))
                                .padding(.top, 10)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 30)
                    .onSubmit {
                        switch focusedField {
                            case .identifier: focusedField = .password
                            default: focusedField = nil
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .onSubmit {
                    if focusedField == .identifier {
                        focusedField = .password
                    } else {
                        focusedField = nil
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize) // Only bounces if content overflows
        }
        .overlay(
            NavigationBar(onBackTap: {
                focusedField = nil
                Task {
                    authViewModel.navigate(to: .onboarding)
                }
            }), alignment: .top
        )
        // Dismisses keyboard when tapping the background
        .onTapGesture {
            focusedField = nil
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private var isFormInvalid: Bool {
        viewModel.identifier.isEmpty || viewModel.password.isEmpty
    }
    
    private var signupRedirectSection: some View {
        HStack (spacing: 4) {
            Text("No account?")
                .foregroundColor(Color("TextColor"))
            
            Button {
                focusedField = nil
                authViewModel.navigate(to: .signup)
            } label: {
                Text("Create one.")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 15)
        .font(.custom("OpenSans-Regular", size: 17))
    }
}



