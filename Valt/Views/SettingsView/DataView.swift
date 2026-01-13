import SwiftUI

struct DataView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
            sectionHeader("How Valt Uses Your Data")
            
            NavigationLink(destination: Text("OpenAI Prompts")) { settingsRow(title: "OpenAI Prompts") }
                .padding(.horizontal, 15)
                .font(.custom("OpenSans-SemiBold", size: 17))
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

    private func settingsRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("OpenSans-Regular", size: 17))
                .foregroundColor(Color("TextColor"))
            Spacer()
            Image("rightArrowIcon")
                .resizable()
                .frame(width: 14, height: 14)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
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
