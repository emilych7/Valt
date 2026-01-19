import SwiftUI

@MainActor
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    @StateObject private var viewModel = SignUpViewModel()
    
    @FocusState private var focusedField: Field?
    
    enum Field { case username, email, password, passwordConfirmation }
    
    var body: some View {
        ZStack {
            Color("AppBackgroundColor").ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 0) {
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.10)
                    
                    HStack {
                        Text("Create an Account")
                            .font(.custom("OpenSans-SemiBold", size: 30))
                            .foregroundColor(Color("TextColor"))
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    
                    VStack {
                        // Username Field
                        signUpTextField(title: "Username", text: $viewModel.username, placeholder: "Username", field: .username)
                            .padding(.top, 20)
                        
                        // Email Field
                        signUpTextField(title: "Email", text: $viewModel.email, placeholder: "Email", field: .email, keyboardType: .emailAddress)
                        
                        // Password Field
                        signUpSecureField(title: "Password", text: $viewModel.password, placeholder: "Password", field: .password)
                        
                        // Re-Enter Password Field
                        signUpSecureField(title: "Re-Enter Password", text: $viewModel.passwordConfirmation, placeholder: "Re-Enter Password", field: .passwordConfirmation)
                        
                        VStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity, minHeight: 60)
                                    .background(Color("RequestButtonColor"))
                                    .cornerRadius(12)
                            } else {
                                Button(action: {
                                    Task { await viewModel.signUp() }
                                }) {
                                    Text("Sign Up")
                                        .foregroundColor(.white)
                                        .font(.custom("OpenSans-Bold", size: 20))
                                        .frame(maxWidth: .infinity, minHeight: 60)
                                        .background(Color("RequestButtonColor"))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.top, 15)
                        
                        Socials(title: "or sign up using") {
                            // Google Tap Logic
                            print("Google Sign Up Tapped")
                        } onAppleTap: {
                            // Apple Tap Logic
                            print("Apple Sign Up Tapped")
                        }
                        
                        loginRedirectSection
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.custom("OpenSans-Regular", size: 14))
                                .padding(.top, 10)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 50)
                }
            }
            .scrollIndicators(.hidden)
            .onTapGesture {
                focusedField = nil
            }
        }
        .overlay(
            NavigationBar(onBackTap: {
                authViewModel.navigate(to: .onboarding)
            }),
            alignment: .top
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func signUpTextField(title: String, text: Binding<String>, placeholder: String, field: Field, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(spacing: 5) {
            HStack {
                Text(title).font(.custom("OpenSans-Regular", size: 17)).foregroundColor(Color("TextColor"))
                Spacer()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .foregroundColor(Color("TextFieldBackground"))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("TextFieldBorder"), lineWidth: 1))
                
                TextField(placeholder, text: text)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(keyboardType)
                    .padding(.horizontal)
                    .focused($focusedField, equals: field)
            }
        }
        .padding(.bottom, 5)
    }
    
    private func signUpSecureField(title: String, text: Binding<String>, placeholder: String, field: Field) -> some View {
        VStack(spacing: 5) {
            HStack {
                Text(title).font(.custom("OpenSans-Regular", size: 17)).foregroundColor(Color("TextColor"))
                Spacer()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .foregroundColor(Color("TextFieldBackground"))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("TextFieldBorder"), lineWidth: 1))
                
                SecureField(placeholder, text: text)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)
                    .focused($focusedField, equals: field)
                    .textContentType(.oneTimeCode)
                    .submitLabel(.done)
            }
        }
        .padding(.vertical, 5)
    }
    
    private var loginRedirectSection: some View {
        HStack (spacing: 3) {
            Text("Already have an account?")
                .foregroundColor(Color("TextColor"))
                .font(.custom("OpenSans-Regular", size: 17))
            
            Button {
                authViewModel.navigate(to: .login)
            } label: {
                Text("Log In")
            }
            .font(.custom("OpenSans-Regular", size: 17))
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }
}
