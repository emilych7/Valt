import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                CustomHeader(title: "Account Preferences", buttonTitle: "Exit") {
                    dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        profileSection
                        displaySection
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
    
    private var headerSection: some View {
        HStack {
            Text("Account Preferences")
                .font(.custom("OpenSans-SemiBold", size: 24))
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            Button { dismiss() } label: {
                ZStack {
                    HStack (spacing: 5) {
                        Image("exitDynamicIcon")
                            .resizable()
                            .frame(width: 17, height: 17)
                        Text("Exit")
                            .foregroundColor(Color("TextColor"))
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                }
                .background(Color("BubbleColor"))
                .cornerRadius(12)
                
                
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 15)
    }
    
    private var profileSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Profile Information")
            
            NavigationLink(destination: UpdateFieldView(fieldType: .username)) {
                settingsRow(title: "Username", image: "usernameIcon")
            }
            .padding(.horizontal, 15)
            .font(.custom("OpenSans-SemiBold", size: 17))
            
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: UpdateFieldView(fieldType: .email)) {
                settingsRow(title: "Email", image: "emailIcon")
            }
            .padding(.horizontal, 15)
            .font(.custom("OpenSans-SemiBold", size: 17))
            
            Divider()
                .frame(height: 1)
                .background(Color("TextFieldBorder"))
            
            NavigationLink(destination: UpdateFieldView(fieldType: .phone)) {
                settingsRow(title: "Phone", image: "phoneIcon")
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 5)
            .font(.custom("OpenSans-SemiBold", size: 17))
        }
        .background(Color("TextFieldBackground"))
        .cornerRadius(12)
    }
    
    private var displaySection: some View {
        VStack(spacing: 0) {
            sectionHeader("Display")
            NavigationLink(destination: Text("Appearance")) { settingsRow(title: "Appearance", image: "appearanceIcon") }
                .padding(.horizontal, 15)
                .padding(.bottom, 5)
                .font(.custom("OpenSans-SemiBold", size: 17))
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
        PreferencesView()
            .environmentObject(mockAuth)
            .environmentObject(mockSettings)
    }
}
