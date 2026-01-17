import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                CustomHeader(title: "Account Preferences", buttonTitle: "Exit") {
                    dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        profileSection
                        displaySection
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
    
    private var profileSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Profile Information")
            
            NavigationLink(destination: UpdateFieldView(fieldType: .username)) {
                SettingsRow(title: "Username", icon: "usernameIcon")
            }
            .padding(.horizontal, 15)
            .font(.custom("OpenSans-SemiBold", size: 17))
            
            CustomDivider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: UpdateFieldView(fieldType: .email)) {
                SettingsRow(title: "Email", icon: "emailIcon")
            }
            .padding(.horizontal, 15)
            .font(.custom("OpenSans-SemiBold", size: 17))
            
            CustomDivider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: UpdateFieldView(fieldType: .phone)) {
                SettingsRow(title: "Phone", icon: "phoneIcon")
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 5)
            .font(.custom("OpenSans-SemiBold", size: 17))
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private var displaySection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Display")
            NavigationLink(destination: Text("Appearance")) { SettingsRow(title: "Appearance", icon: "appearanceIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .font(.custom("OpenSans-SemiBold", size: 17))
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
}

#Preview("Logged In State") {
    let mockAuth = AuthViewModel()
    let mockSettings = SettingsViewModel()
    
    return NavigationView {
        PreferencesView()
            .environmentObject(mockAuth)
            .environmentObject(mockSettings)
    }
}
