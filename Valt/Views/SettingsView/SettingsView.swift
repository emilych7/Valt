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
                VStack(spacing: 0) {
                    NavigationLink(destination: PreferencesView()) {
                        SettingsMainRow(title: "Account Preferences")
                    }
                    .padding(.horizontal, 15)
                    
                    NavigationLink(destination: DataView()) {
                        SettingsMainRow(title: "Data Privacy")
                    }
                    .padding(.horizontal, 15)
                    
                    NavigationLink(destination: ActivityView()) {
                        SettingsMainRow(title: "Activity")
                    }
                    .padding(.horizontal, 15)
                    
                    NavigationLink(destination: SecurityView()) {
                        SettingsMainRow(title: "Security")
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
                    
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
            authViewModel.signOut()
        }) {
            Text("Log Out")
                .font(.custom("OpenSans-Bold", size: 17))
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

