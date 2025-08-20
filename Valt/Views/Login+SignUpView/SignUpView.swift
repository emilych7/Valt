import SwiftUI

@MainActor
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var bannerManager: BannerManager
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    
    enum Field {
        case username, password, passwordConfirmation
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Spacer(minLength: geometry.size.height * 0.10)
                        
                        HStack {
                            Text("Create an Account")
                                .font(.custom("OpenSans-SemiBold", size: 30))
                                .foregroundColor(Color("TextColor"))
                            Spacer()
                        }
                        .padding(.horizontal, 25)
                        
                        VStack {
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
                                                .stroke(Color("TextFieldBorder"), lineWidth: 1)
                                        )
                                    
                                    TextField("Username", text: $username)
                                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                        .textFieldStyle(.plain)
                                        .keyboardType(.default)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal)
                                        .focused($focusedField, equals: .username)
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
                                    
                                    TextField("Email", text: $email)
                                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                        .textFieldStyle(.plain)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal)
                                        .focused($focusedField, equals: .username)
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
                                    SecureField("Password", text: $password)
                                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                        .textFieldStyle(.plain)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal)
                                        .focused($focusedField, equals: .password)
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
                                    SecureField("Re-Enter Password", text: $passwordConfirmation)
                                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                                        .textFieldStyle(.plain)
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal)
                                        .focused($focusedField, equals: .passwordConfirmation)
                                }
                            }
                            .padding(.top, 5)
                            
                            VStack {
                                Button("Sign Up") {
                                    print("Reached")
                                    Task {
                                        /*
                                        if ($password != $passwordConfirmation) {
                                            print("Passwords do not match")
                                            bannerManager.show("Passwords do not match")
                                        }
                                         */
                                        if (!authViewModel.isValidPassword(password)) || (password != passwordConfirmation) {
                                            let missing = authViewModel.getMissingValidation(password)
                                            print("Missing: \(missing)")
                                            // bannerManager.show("\(missing)")
                                            print("Passwords do not match")
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
                            
                            HStack (spacing: 3) {
                                Text("Already have an account?")
                                    .foregroundColor(Color("TextColor"))
                                    .font(.custom("OpenSans-Regular", size: 17))
                                Button("Log in.") {
                                        // Navigate to SignUpView later
                                }
                                .font(.custom("OpenSans-Regular", size: 17))
                            }
                            .padding(.vertical, 10)
                            
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                    }
                    .padding(.horizontal, 40)
                        
                        Spacer(minLength: geometry.size.height * 0.1)
                        
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
    
}
