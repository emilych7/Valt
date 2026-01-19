import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bannerManager: BannerManager
    
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            ScrollView {
                VStack (spacing: 0) {
                
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.10)
                    
                    HStack {
                        Text("Welcome Back")
                            .font(.custom("OpenSans-SemiBold", size: 30))
                            .foregroundColor(Color("TextColor"))
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                
                VStack {
                    // Username or Email
                    VStack(spacing: 5) {
                        HStack {
                            Text("Username or Email")
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            Spacer()
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50)
                                .foregroundColor(Color("TextFieldBackground"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("TextFieldBorder"), lineWidth: 1)
                                )
                            
                            TextField("Username or Email", text: $viewModel.identifier)
                                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                .textFieldStyle(.plain)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .padding(.horizontal)
                                // .focused($focusedField, equals: .username)
                                .focused($isTextFieldFocused)
                                .onTapGesture {
                                    isTextFieldFocused = true
                                }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 5)
                    
                    // Password
                    VStack(spacing: 5) {
                        HStack {
                            Text("Password")
                                .font(.custom("OpenSans-Regular", size: 17))
                                .foregroundColor(Color("TextColor"))
                            
                            Spacer()
                            
                            Button("Forgot Password?") {
                                // Forgot password logic
                            }
                            .font(.custom("OpenSans-Regular", size: 15))
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 50)
                                .foregroundColor(Color("TextFieldBackground"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("TextFieldBorder"), lineWidth: 1)
                                )
                            
                            SecureField("Password", text: $viewModel.password)
                                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                .textFieldStyle(.plain)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .padding(.horizontal)
                                // .focused($focusedField, equals: .password)
                                .focused($isTextFieldFocused)
                                .onTapGesture {
                                    isTextFieldFocused = true
                                }
                            
                        }
                    }
                    .padding(.top, 5)
                    
                    VStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color("RequestButtonColor"))
                                .cornerRadius(12)
                        } else {
                            Button(action: {
                                Task { await viewModel.performSignIn() }
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
                    
                    // Social buttons
                    Socials(title: "or login using") {
                        // Google Tap Logic
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            Task {
                                await viewModel.signInWithGoogle(presenting: rootVC)
                            }
                        }
                    } onAppleTap: {
                        // Apple Tap Logic
                        print("Apple Login Tapped")
                    }
                    
                    signupRedirectSection
                }
                .padding(.horizontal, 40)
                
            }
        }
        .scrollIndicators(.hidden)
        .overlay(
            NavigationBar(onBackTap: {
                authViewModel.navigate(to: .onboarding)
            }),
            alignment: .top
        )
        .background(Color("AppBackgroundColor"))
    }
    }
    
    private var signupRedirectSection: some View {
        HStack (spacing: 3) {
            Text("No account?")
                .foregroundColor(Color("TextColor"))
                .font(.custom("OpenSans-Regular", size: 17))
            
            Button {
                authViewModel.navigate(to: .signup)
            } label: {
                Text("Let's make one.")
            }
            .font(.custom("OpenSans-Regular", size: 17))
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
    }
}



