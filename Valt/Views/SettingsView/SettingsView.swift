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
                        SectionHeader(title: "General Settings")
                        
                        NavigationLink(destination: PreferencesView()) {
                            SettingsRow(title: "Account Preferences", icon: "userIcon")
                        }
                        
                        CustomDivider()
                        
                        NavigationLink(destination: DataView()) {
                            SettingsRow(title: "Data Privacy", icon: "dataIcon")
                        }
                        
                        CustomDivider()
                        
                        NavigationLink(destination: ActivityView()) {
                            SettingsRow(title: "Activity", icon: "activityIcon")
                        }
                        
                        CustomDivider()
                        
                        NavigationLink(destination: SecurityView()) {
                            SettingsRow(title: "Security", icon: "securityIcon")
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

