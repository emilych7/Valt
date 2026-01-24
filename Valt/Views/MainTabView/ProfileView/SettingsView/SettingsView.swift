import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            
            SettingsHeader(title: "Settings", buttonTitle: "Exit") {
                dismiss()
            }
            
            ScrollView {
                VStack(spacing: 10) {
                    NavigationLink(destination: PreferencesView()) {
                        SettingsMainRow(title: "Account Preferences")
                    }
                    
                    NavigationLink(destination: DataView()) {
                        SettingsMainRow(title: "Data Privacy")
                    }
                    
                    NavigationLink(destination: ActivityView()) {
                        SettingsMainRow(title: "Activity")
                    }
                    
                    NavigationLink(destination: SecurityView()) {
                        SettingsMainRow(title: "Security")
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
            }
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
        .scrollBounceBehavior(.basedOnSize)
        .environmentObject(settingsViewModel)
        }
    }
}

#Preview("Logged In State") {
    let mockAuth = AuthViewModel()
    return SettingsView()
        .environmentObject(mockAuth)
}

