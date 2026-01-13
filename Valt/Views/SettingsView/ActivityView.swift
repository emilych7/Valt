import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                CustomHeader(title: "Activity", buttonTitle: "Exit") {
                    dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        interactionSection
                        archiveSection
                        timeSection
                        managementSection
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
    
    private var interactionSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Interactions")
            
            NavigationLink(destination: Text("Favorited Content")) { SettingsRow(title: "Favorited", icon: "usernameIcon") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            
            NavigationLink(destination: Text("Published Content")) { SettingsRow(title: "Published", icon: "usernameIcon") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Shared Content")) { SettingsRow(title: "Shared", icon: "usernameIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .font(.custom("OpenSans-SemiBold", size: 17))
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private var archiveSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Archived and Removed Content")
            NavigationLink(destination: Text("Recently Deleted")) { SettingsRow(title: "Recently Deleted", icon: "usernameIcon") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Archived")) { SettingsRow(title: "Archived", icon: "usernameIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .font(.custom("OpenSans-SemiBold", size: 17))
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private var timeSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Account Management")
            NavigationLink(destination: Text("Deactivate Account")) {
                SettingsRow(title: "Screen Time", icon: "usernameIcon")
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
                    .font(.custom("OpenSans-SemiBold", size: 17))
            }
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private var managementSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Account Management")
            NavigationLink(destination: Text("Deactivate Account")) {
                SettingsRow(title: "Deactivate Account", icon: "trashIcon")
                    .padding(.horizontal, 15)
                    .padding(.bottom, 5)
                    .font(.custom("OpenSans-SemiBold", size: 17))
            }
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
        ActivityView()
            .environmentObject(mockAuth)
            .environmentObject(mockSettings)
    }
}
