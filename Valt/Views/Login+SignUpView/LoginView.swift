import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
            ScrollView {
                VStack {
                    HStack {
                        Text("Welcome back")
                            .font(.custom("OpenSans-SemiBold", size: 30))
                            .foregroundColor(Color("TextColor"))
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 40)
                    
                    VStack {
                        VStack (spacing: 5){
                            HStack {
                                Text("Username or Email")
                                    .font(.custom("OpenSans-Regular", size: 17))
                                    .foregroundColor(Color("TextColor"))
                                
                                Spacer ()
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 50)
                                    .foregroundColor(Color("TextFieldBackground"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("TextFieldBorder"), lineWidth: 1) // border
                                    )
                                
                                TextField("Username or Email", text: $email)
                                    .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                    .textFieldStyle(.plain)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .padding(.horizontal)
                                    .contentShape(Rectangle())
                                    .focused($isTextFieldFocused)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                        
                        VStack (spacing: 5) {
                            HStack {
                                Text("Password")
                                    .font(.custom("OpenSans-Regular", size: 17))
                                    .foregroundColor(Color("TextColor"))
                                
                                Spacer ()
                                
                                Button("Forgot Password?") {
                                    Task {
                                        await authViewModel.resetPassword(email: email)
                                    }
                                }
                                .font(.custom("OpenSans-Regular", size: 15))
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 50)
                                    .foregroundColor(Color("TextFieldBackground"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("TextFieldBorder"), lineWidth: 1) // border
                                    )
                                    SecureField("Password", text: $password)
                                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                        .textFieldStyle(.plain)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal)
                                        .contentShape(Rectangle())
                                        .focused($isTextFieldFocused)
                            }
                        }
                        .padding(.top, 5)
                        
                        VStack {
                            Button(action: {
                                print("'Log In' button pressed")
                                Task {
                                    await authViewModel.signIn(email: email, password: password)
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

                        
                        ZStack {
                            Text("or login using")
                                .foregroundColor(Color("TextColor"))
                                .font(.custom("OpenSans-Regular", size: 16))
                        }
                        .padding(.vertical, 10)
                        
                        HStack(spacing: 25) {
                            Button {
                                // add Google Sign In
                            } label: {
                                Image("Google")
                                    .padding(.vertical, 15)
                                    .frame(maxWidth: .infinity)
                                    .background(Color("AuthOptionsBackground"), in: RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button {
                                // add Apple Sign In
                            } label: {
                                Image("appleIcon")
                                    .padding(.vertical, 15)
                                    .frame(maxWidth: .infinity)
                                    .background(Color("AuthOptionsBackground"), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        HStack (spacing: 5) {
                            Text("No account?")
                                .foregroundColor(Color("TextColor"))
                                .font(.custom("OpenSans-Regular", size: 17))
                            Button("Let's make one.") {
                                // Navigate to SignUpView later
                                dismiss()
                            }
                        }
                        .padding(.vertical, 10)
                        
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color("AppBackgroundColor"))
        }
    
    // Smoother keyboard dismiss
    func dismissKeyboardSmoothly() {
        DispatchQueue.main.async {
            isTextFieldFocused = false
        }
    }
}

#Preview {
    LoginView()
}
