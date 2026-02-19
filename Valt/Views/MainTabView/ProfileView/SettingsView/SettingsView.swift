import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabManager: TabManager
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDraft: Draft?
    @Binding var showNote: Bool
    
    var body: some View {
        NavigationStack {
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
                        
                        NavigationLink(destination: ActivityView(selectedDraft: $selectedDraft, showNote: $showNote)) {
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
        .onAppear {
            tabManager.setTabBarHidden(true)
        }
        .onDisappear { tabManager.setTabBarHidden(false) }
        .scrollBounceBehavior(.basedOnSize)
        .environmentObject(settingsViewModel)
        }
    }
}
