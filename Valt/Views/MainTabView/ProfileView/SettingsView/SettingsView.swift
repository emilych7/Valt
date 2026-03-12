import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabManager: TabManager
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDraft: Draft?
    @Binding var showNote: Bool
    
    @State var showLogOutConfirmation: Bool = false
    
    var body: some View {
        // 1. Use a geometry reader or just a ZStack to ensure the background is solid
        ZStack {
            Color("TextFieldBackground")// .ignoresSafeArea()
            
            ScrollView {
                // 2. Put the Header INSIDE the VStack that is INSIDE the ScrollView
                VStack(spacing: 0) {
                    SettingsHeader(title: "Settings", buttonTitle: "Exit") {
                        dismiss()
                    }
                    
                    profileSection
                        .padding(.bottom, 10)
                    archiveSection
                        .padding(.bottom, 10)
                    resetPasswordSection
                        .padding(.bottom, 10)
                    dataSection
                        .padding(.bottom, 10)
                    managementSection
                    
                    Spacer()
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            tabManager.setTabBarHidden(true)
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Profile Information")
            
            NavigationLink(destination: UpdateFieldView(fieldType: .username)) {
                SettingsRow(title: "Username", icon: "usernameIcon")
            }
            .padding(.horizontal, 15)

            NavigationLink(destination: UpdateFieldView(fieldType: .email)) {
                SettingsRow(title: "Email", icon: "emailIcon")
            }
            .padding(.horizontal, 15)
            
            NavigationLink(destination: UpdateAppearanceView()) { SettingsRow(title: "Appearance", icon: "appearanceIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
        }
        .background(Color("AppBackgroundColor"))
    }

    private var managementSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Account Management")
            
            Button(action: {
                showLogOutConfirmation =  true
            }) {
                SettingsRow(title: "Log Out", icon: "logoutIcon")
                    .padding(.horizontal, 15)
            }
            .alert("Are you sure you want to log out?", isPresented: $showLogOutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Continue") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        authViewModel.signOut()
                    }
                }
                .foregroundStyle(Color(("TextColor")))
            }
            
            NavigationLink(destination: DeactivateView().navigationBarBackButtonHidden(true)) {
                SettingsRow(title: "Delete Account", icon: "trashIcon", isDestructive: true)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
            }
        }
        .background(Color("AppBackgroundColor"))
    }
    
    private var archiveSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Archived and Removed Content")
            NavigationLink(destination: ArchiveView(selectedDraft: $selectedDraft, showNote: $showNote).navigationBarBackButtonHidden(true)) { SettingsRow(title: "Archived", icon: "archiveIcon") }
                .padding(.horizontal, 15)

            NavigationLink(destination: Text("Recently Deleted")) { SettingsRow(title: "Recently Deleted", icon: "deleteIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
            
            
        }
        .background(Color("AppBackgroundColor"))
    }
    
    private var dataSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "How Valt Uses Your Data")
            
            NavigationLink(destination: Text("OpenAI Prompts")) { SettingsRow(title: "OpenAI Prompts", icon: "promptsIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
        }
        .background(Color("AppBackgroundColor"))
    }

    private var resetPasswordSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Password Protection")
            
            NavigationLink(destination: Text("Reset Password")) { SettingsRow(title: "Reset Password", icon: "passwordIcon") }
                .padding(.horizontal, 15)
            
            NavigationLink(destination: Text("Two-Factor")) { SettingsRow(title: "Two-Factor", icon: "twoFactorIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
            
        }
        .background(Color("AppBackgroundColor"))
    }
}
