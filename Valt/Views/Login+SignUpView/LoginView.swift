import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var focusedField: Field?
    @State var offset: CGFloat = 0
    @State private var emailOrUsername = ""
    @State private var password = ""
    
    enum Field {
        case username, password
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Spacer(minLength: geometry.size.height * 0.10)
                        
                        HStack {
                            Text("Welcome back")
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
                                    
                                    TextField("Username or Email", text: $emailOrUsername)
                                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                        .textFieldStyle(.plain)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal)
                                        .focused($focusedField, equals: .username)
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
                                    
                                    SecureField("Password", text: $password)
                                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                        .textFieldStyle(.plain)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal)
                                        .focused($focusedField, equals: .password)
                                        .onTapGesture {
                                            isTextFieldFocused = true
                                        }
                                    
                                }
                            }
                            .padding(.top, 5)
                            
                            // Log In button
                            VStack {
                                Button(action: {
                                    print("'Log In' button pressed")
                                    Task {
                                        await authViewModel.signIn(usernameOrEmail: emailOrUsername, password: password)
                                    }
                                }) {
                                    Text("Log In")
                                        .foregroundColor(.white)
                                        .font(.custom("OpenSans-Bold", size: 20))
                                        .frame(maxWidth: .infinity, minHeight: 60)
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 15)
                            
                            // OR text
                            Text("or login using")
                                .foregroundColor(Color("TextColor"))
                                .font(.custom("OpenSans-Regular", size: 16))
                                .padding(.vertical, 10)
                            
                            // Social buttons
                            HStack(spacing: 25) {
                                Button {
                                    // Google Sign In
                                    if let rootVC = UIApplication.shared.connectedScenes
                                            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                                            .first {
                                            Task {
                                                await authViewModel.signInWithGoogle(presenting: rootVC)
                                            }
                                        }
                                } label: {
                                    Image("Google")
                                        .padding(.vertical, 15)
                                        .frame(maxWidth: .infinity)
                                        .background(Color("AuthOptionsBackground"), in: RoundedRectangle(cornerRadius: 12))
                                }
                                
                                Button {
                                    // Apple Sign In
                                } label: {
                                    Image("appleIcon")
                                        .padding(.vertical, 15)
                                        .frame(maxWidth: .infinity)
                                        .background(Color("AuthOptionsBackground"), in: RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                            // Sign up link
                            HStack(spacing: 5) {
                                Text("No account?")
                                    .foregroundColor(Color("TextColor"))
                                    .font(.custom("OpenSans-Regular", size: 17))
                                Button("Let's make one.") {
                                    dismiss()
                                }
                                .font(.custom("OpenSans-Regular", size: 17))
                            }
                            .padding(.vertical, 10)
                            
                            // Error message
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer(minLength: geometry.size.height * 0.2)
                    }
                    
                }
                .scrollIndicators(.hidden)
                .background(Color("AppBackgroundColor"))
                .onTapGesture {
                    focusedField = nil // Dismiss keyboard
                }
            }
            .overlay(topNavigationBar, alignment: .top)
        }
    }
    
    private var topNavigationBar: some View {
        HStack {
            Button("Back") {
                dismiss()
            }
            .font(.custom("OpenSans-SemiBold", size: 13))
            .foregroundColor(Color("TextColor"))
            .buttonStyle(.borderedProminent)
            .cornerRadius(14)
            .tint(Color("BubbleColor").opacity(0.50))

            Spacer()

        }
        .padding(.horizontal, 25)
        .padding(.vertical, 10)
        .background(Color("AppBackgroundColor"))
    }
    
    // Smoother keyboard dismiss
    func dismissKeyboardSmoothly() {
        DispatchQueue.main.async {
            isTextFieldFocused = false
        }
    }
}
