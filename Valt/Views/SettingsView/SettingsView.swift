import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            
            CustomHeader(title: "Settings", buttonTitle: "Exit") {
                dismiss()
            }
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(spacing: 0) {
                        sectionHeader("General Settings")
                        
                        NavigationLink(destination: PreferencesView()) {
                            settingsRow(title: "Account Preferences", icon: "userIcon")
                        }
                        
                        divider
                        
                        NavigationLink(destination: DataView()) {
                            settingsRow(title: "Data Privacy", icon: "dataIcon")
                        }
                        
                        divider
                        
                        NavigationLink(destination: ActivityView()) {
                            settingsRow(title: "Activity", icon: "activityIcon")
                        }
                        
                        divider
                        
                        NavigationLink(destination: SecurityView()) {
                            settingsRow(title: "Security", icon: "securityIcon")
                        }
                    }
                    .background(Color("TextFieldBackground"))
                    .cornerRadius(12)
                    
                    logoutSection
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
        .environmentObject(settingsViewModel)
            
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-SemiBold", size: 18))
                .foregroundColor(Color("TextColor"))
            Spacer()
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 10)
    }

    private func settingsRow(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(title)
                .font(.custom("OpenSans-Regular", size: 17))
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            Image("rightArrowIcon")
                .resizable()
                .frame(width: 14, height: 14)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var divider: some View {
        Divider()
            .frame(height: 1)
            .background(Color("TextFieldBorder"))
            .padding(.horizontal, 15)
    }
    
    private var logoutSection: some View {
        Button(action: {
            do {
                try Auth.auth().signOut()
                authViewModel.isAuthenticated = false
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }) {
            Text("Log Out")
                .font(.custom("OpenSans-Bold", size: 19))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("ValtRed"))
                .cornerRadius(12)
        }
        .padding(.top, 10)
    }
}

#Preview("Logged In State") {
    let mockAuth = AuthViewModel()
    return SettingsView()
        .environmentObject(mockAuth)
}

