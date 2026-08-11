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
        ZStack (alignment: .top) {
            Color("AppBackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 0) {
                SettingsHeader(title: "Settings", imageTitle: "exitDynamicIcon", buttonTitle: "Exit") {
                    dismiss()
                }
                .animation(nil, value: showNote)
                .background(Color("AppBackgroundColor"))
                
                ScrollView {
                    VStack(spacing: 0) {
                        profileSection
                            .padding(.bottom, 10)
//                        archiveSection
//                            .padding(.bottom, 10)
                        resetPasswordSection
                            .padding(.bottom, 10)
                        dataSection
                            .padding(.bottom, 10)
                        managementSection
                        
                        Spacer()
                    }
                    .padding(.bottom, 60)
                }
                .scrollBounceBehavior(.always)
                .background(Color("TextFieldBackground"))
            }
            .background(Color("AppBackgroundColor")/*.ignoresSafeArea()*/)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                tabManager.setTabBarHidden(true)
            }
            .transaction { transaction in
                transaction.animation = .smooth(duration: 0.0)
            }
        }
     }
    
    private var profileSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Profile")
            
            NavigationLink(destination: UpdateFieldView(fieldType: .username)) {
                SettingsRow(title: "Username", icon: "usernameIcon")
            }
            .padding(.horizontal, 10)

            NavigationLink(destination: UpdateFieldView(fieldType: .email)) {
                SettingsRow(title: "Email", icon: "emailIcon")
            }
            .padding(.horizontal, 10)
            
            NavigationLink(destination: UpdateAppearanceView()) { SettingsRow(title: "Appearance", icon: "appearanceIcon") }
                .padding(.horizontal, 10)
                // .padding(.bottom, 5)
            
            NavigationLink(destination: ArchiveView(selectedDraft: $selectedDraft, showNote: $showNote).navigationBarBackButtonHidden(true)) { SettingsRow(title: "Archived", icon: "archiveIcon") }
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
        }
        .background(Color("AppBackgroundColor"))
    }

    private var managementSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Support")
            
            Button(action: {
                showLogOutConfirmation =  true
            }) {
                SettingsRow(title: "Log Out", icon: "logoutIcon")
                    .padding(.horizontal, 10)
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
            
            NavigationLink(destination: Text("Report an Issue")) { SettingsRow(title: "Report an Issue", icon: "reportIcon") }
                .padding(.horizontal, 10)
            
            NavigationLink(destination: DeactivateView().navigationBarBackButtonHidden(true)) {
                SettingsRow(title: "Delete Account", icon: "trashIcon", isDestructive: true)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
            }
        }
        .background(Color("AppBackgroundColor"))
    }
    
    private var dataSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "How Valt Uses Your Data")
            
            NavigationLink(destination: Text("OpenAI Prompts")) { SettingsRow(title: "OpenAI Prompts", icon: "promptsIcon") }
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
        }
        .background(Color("AppBackgroundColor"))
    }

    private var resetPasswordSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Password Protection")
            
            NavigationLink(destination: ResetPasswordView()) { SettingsRow(title: "Reset Password", icon: "passwordIcon") }
                .padding(.horizontal, 10)
            
            NavigationLink(destination: Text("Two-Factor")) { SettingsRow(title: "Two-Factor", icon: "twoFactorIcon") }
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
            
        }
        .background(Color("AppBackgroundColor"))
    }
}
