import SwiftUI

struct SecurityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                CustomHeader(title: "Security", buttonTitle: "Exit") {
                    dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        resetPasswordSection
                        twoFactorAuthenticationSection
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var twoFactorAuthenticationSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Two-Factor Authentication")
            
            NavigationLink(destination: Text("Two-Factor")) { SettingsRow(title: "Two-Factor", icon: "emailIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .font(.custom("OpenSans-SemiBold", size: 17))
            
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private var resetPasswordSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Password Protection")
            
            NavigationLink(destination: Text("Reset Password")) { SettingsRow(title: "Reset Password", icon: "emailIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .font(.custom("OpenSans-SemiBold", size: 17))
            
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 18))
            Spacer()
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 10)
    }
}

#Preview("Logged In State") {
    let mockAuth = AuthViewModel()
    let mockSettings = SettingsViewModel()
    
    return NavigationView {
        SecurityView()
            .environmentObject(mockAuth)
            .environmentObject(mockSettings)
    }
}
