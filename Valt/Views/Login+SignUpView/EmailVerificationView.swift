import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Verify your email")
                .font(.custom("OpenSans-Bold", size: 20))
            
            Text("We sent a link to \(viewModel.email). Please click the link to continue.")
                .font(.custom("OpenSans-Regular", size: 16))
                .multilineTextAlignment(.center)
            
            Button("Resend Email") {
                viewModel.resendEmail()
            }
            .font(.custom("OpenSans-SemiBold", size: 16))
        }
    }
}
