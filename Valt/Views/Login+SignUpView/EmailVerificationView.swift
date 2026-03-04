import SwiftUI

struct EmailVerificationView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                Spacer()
                
                Image(systemName: "envelope.badge")
                    .resizable()
                    .frame(width: 80, height: 60)
                    .foregroundColor(Color("TextColor"))
                
                Spacer()
            }
            .padding(.vertical, 10)
            
            Text("We sent a link to \(viewModel.email). Please click the link to continue.")
                .font(.custom("OpenSans-Regular", size: 16))
            
            Button("Resend Email") {
                viewModel.resendEmail()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color("RequestButtonColor"))
            .cornerRadius(12)
            .font(.custom("OpenSans-SemiBold", size: 16))
        }
    }
}
