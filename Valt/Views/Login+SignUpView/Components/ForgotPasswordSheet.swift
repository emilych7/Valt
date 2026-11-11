import SwiftUI

struct ForgotPasswordSheet: View {
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var emailFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackgroundColor").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "key.horizontal")
                            .font(.system(size: 38))
                            .foregroundColor(Color("TextColor"))
                            .padding(.top, 10)
                        
                        Text("Reset Your Password")
                            .font(.custom("OpenSans-SemiBold", size: 22))
                            .foregroundColor(Color("TextColor"))
                        
                        Text("Enter your email address or username and we'll send you a link to create or reset your password.")
                            .font(.custom("OpenSans-Regular", size: 14))
                            .foregroundColor(Color("TextColor").opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email or Username")
                            .font(.custom("OpenSans-SemiBold", size: 14))
                            .foregroundColor(Color("TextColor").opacity(0.85))
                            .padding(.horizontal, 6)
                        
                        TextField("Username or Email", text: $viewModel.resetEmail)
                            .font(.custom("OpenSans-Regular", size: 15))
                            .foregroundColor(Color("TextColor"))
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .focused($emailFocused)
                            .padding(.horizontal, 18)
                            .frame(height: 50)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color("TextFieldBackground"))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(
                                                emailFocused ?
                                                Color("TextColor").opacity(0.35) :
                                                Color("TextColor").opacity(0.12),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(emailFocused ? 0.08 : 0.03), radius: 8, x: 0, y: 3)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    if let success = viewModel.resetSuccessMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(success)
                                .font(.custom("OpenSans-Regular", size: 14))
                                .foregroundColor(Color("TextColor"))
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.green.opacity(0.12))
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    if let error = viewModel.resetErrorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.custom("OpenSans-Regular", size: 14))
                                .foregroundColor(.red)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red.opacity(0.12))
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    AuthActionButton(
                        title: viewModel.resetSuccessMessage == nil ? "Send Reset Link" : "Send Again",
                        isLoading: viewModel.isSendingReset,
                        isDisabled: viewModel.resetEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        emailFocused = false
                        Task { await viewModel.sendPasswordReset() }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("OpenSans-SemiBold", size: 16))
                    .foregroundColor(Color("TextColor"))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
