import SwiftUI

struct DataView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                CustomHeader(title: "Data Privacy", buttonTitle: "Exit") {
                    dismiss()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        dataSection
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
    
    private var dataSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "How Valt Uses Your Data")
            
            NavigationLink(destination: Text("OpenAI Prompts")) { SettingsRow(title: "OpenAI Prompts", icon: "promptsIcon") }
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
        DataView()
            .environmentObject(mockAuth)
            .environmentObject(mockSettings)
    }
}
