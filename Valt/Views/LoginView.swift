import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Sign In") {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Forgot Password?") {
                Task {
                    await authViewModel.resetPassword(email: email)
                }
            }
            .font(.footnote)

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            Button("Don't have an account? Sign Up") {
                // Navigate to SignUpView later
            }
        }
    }
    
}
