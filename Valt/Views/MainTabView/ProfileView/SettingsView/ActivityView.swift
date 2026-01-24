import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                SettingsHeader(title: "Activity", buttonTitle: "Exit") {
                    dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        interactionSection
                        archiveSection
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
            SectionHeader(title: "Interactions")
            
            NavigationLink(destination: Text("Favorited Content")) { SettingsRow(title: "Favorited", icon: "favoriteIcon") }
                .padding(.horizontal, 15)
            
            CustomDivider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            
            NavigationLink(destination: Text("Published Content")) { SettingsRow(title: "Published", icon: "publishIcon") }
                .padding(.horizontal, 15)
            
            CustomDivider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Shared Content")) { SettingsRow(title: "Shared", icon: "shareIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private var archiveSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Archived and Removed Content")
            NavigationLink(destination: Text("Recently Deleted")) { SettingsRow(title: "Recently Deleted", icon: "trashIcon") }
                .padding(.horizontal, 15)
            
            CustomDivider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Archived")) { SettingsRow(title: "Archived", icon: "archiveIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
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
