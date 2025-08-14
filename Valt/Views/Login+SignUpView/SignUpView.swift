import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Create an account")
                        .font(.custom("OpenSans-SemiBold", size: 30))
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                // Username Field
                VStack (spacing: 5){
                    HStack {
                        Text("Username")
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
                        
                        TextField("Username", text: $username)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .textFieldStyle(.plain)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 5)
                
                // Email Field
                VStack (spacing: 5){
                    HStack {
                        Text("Email")
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
                        
                        TextField(" ", text: $email)
                            .textFieldStyle(.plain)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 5)
                
                // Password Field
                VStack (spacing: 5){
                    HStack {
                        Text("Password")
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
                        SecureField("              ", text: $password)
                            .textFieldStyle(.plain)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 5)
                
                // Re-Enter Password Field
                VStack (spacing: 5){
                    HStack {
                        Text("Re-Enter Password")
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
                        SecureField("              ", text: $password)
                            .textFieldStyle(.plain)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 5)
                
                VStack {
                    Button("Sign Up") {
                        Task {
                            if !authViewModel.isValidPassword(password) {
                                let missing = authViewModel.getMissingValidation(password)
                                print("Missing: \(missing)")
                            } else {
                                await authViewModel.signUp(email: email, password: password, username: username)
                            }
                            
                        }
                    }
                    .foregroundColor(.white)
                    .font(.custom("OpenSans-Bold", size: 20))
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(.blue)
                    .cornerRadius(12)
                }
                .padding(.top, 15)
                
                ZStack {
                    Text("or sign up using")
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
                
                Spacer()
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                ZStack {
                    HStack (spacing: 3) {
                        Text("Already have an account?")
                            .foregroundColor(Color("TextColor"))
                            .font(.custom("OpenSans-Regular", size: 17))
                        Button("Log in.") {
                            // Navigate to SignUpView later
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .background(Color("AppBackgroundColor"))
        }
    }
    
}
