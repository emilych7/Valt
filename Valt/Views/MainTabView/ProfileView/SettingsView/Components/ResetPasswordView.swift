import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsHeader(title: "Reset Password", imageTitle: "backCarrotIcon", buttonTitle: "Back") {
                dismiss()
            }
            
            Spacer()
            
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color("AppBackgroundColor"))
    }
}
