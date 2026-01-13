import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
            
            NavigationLink(destination: Text("Favorited Content")) { settingsRow(title: "Favorited", image: "emailIcon") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            
            NavigationLink(destination: Text("Published Content")) { settingsRow(title: "Published", image: "emailIcon") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Shared Content")) { settingsRow(title: "Shared", image: "emailIcon") }
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
            NavigationLink(destination: Text("Recently Deleted")) { settingsRow(title: "Recently Deleted", image: "emailIcon") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
            
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: Text("Archived")) { settingsRow(title: "Archived", image: "emailIcon") }
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
                settingsRow(title: "Deactivate Account", image: "emailIcon")
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
                settingsRow(title: "Deactivate Account", image: "trashIcon")
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

    private func settingsRow(title: String, image: String) -> some View {
        HStack {
            Image(image)
                .resizable()
                .frame(width: 15, height: 15)
                .padding(.trailing, 5)
            Text(title)
                .font(.custom("OpenSans-Regular", size: 17))
                .foregroundColor(Color("TextColor"))
            Spacer()
            Image("rightArrowIcon")
                .resizable()
                .frame(width: 14, height: 14)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
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
