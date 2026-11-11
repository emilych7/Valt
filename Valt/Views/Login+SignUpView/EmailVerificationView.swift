import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Spacer()
                Image(systemName: "envelope.badge")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 56)
                    .foregroundColor(Color("TextColor"))
                Spacer()
            }
            .padding(.vertical, 10)
            
            Text("A verification link has been sent to \(viewModel.email). Please check your email to verify your account, or continue now and verify later.")
                .font(.custom("OpenSans-Regular", size: 15))
                .foregroundColor(Color("TextColor").opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 10)
                .padding(.bottom, 25)
            
            VStack(spacing: 12) {
                AuthActionButton(
                    title: "I've Verified My Email",
                    isLoading: viewModel.isLoading,
                    isDisabled: false
                ) {
                    Task {
                        await viewModel.checkVerificationStatus()
                    }
                }
                
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                    viewModel.continueLater()
                } label: {
                    Text("Verify Later")
                        .foregroundColor(Color("TextColor"))
                        .font(.custom("OpenSans-SemiBold", size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color("TextFieldBackground"))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color("TextColor").opacity(0.18), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.resendEmail()
                } label: {
                    Text("Resend Verification Email")
                        .foregroundColor(.blue)
                        .font(.custom("OpenSans-Regular", size: 15))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.top, 10)
            
            if viewModel.emailSentConfirmation {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Verification email resent! Check your inbox.")
                        .foregroundColor(Color("TextColor"))
                        .font(.custom("OpenSans-Regular", size: 14))
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.green.opacity(0.10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.green.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            
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
            }
        }
    }
}
