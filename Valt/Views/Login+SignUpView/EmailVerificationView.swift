import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.circle.fill").font(.system(size: 80)).foregroundColor(.blue)
            Text("Verify Your Email").font(.title.bold())
            Text("We sent a link to \(Auth.auth().currentUser?.email ?? "your email").")
            
            Button("Resend Link") {
                Task { try? await Auth.auth().currentUser?.sendEmailVerification() }
            }
        }
        .onAppear {
            viewModel.startVerificationPolling()
        }
    }
}
