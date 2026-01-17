import SwiftUI

struct UpdateAppearanceView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "Change Appearance", buttonTitle: "Exit") {
                dismiss()
            }
            
            Text("Mode")
                .font(.custom("OpenSans-SemiBold", size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("TextColor"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            
            VStack {
                HStack {
                    // LIGHT MODE
                    appearanceButton(title: "Light", mode: "Light")
                    
                    Spacer()
                    
                    // DARK MODE
                    appearanceButton(title: "Dark", mode: "Dark")
                    
                    Spacer()
                    
                    // AUTO (SYSTEM) MODE
                    appearanceButton(title: "Auto", mode: "Auto")
                }
                .padding(25)
            }
            .background(Color("TextFieldBackground"))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color("AppBackgroundColor"))
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func appearanceButton(title: String, mode: String) -> some View {
        let isSelected = settingsViewModel.selectedAppearance == mode
        
        VStack {
            Image("themeMockup")
                .resizable()
                .frame(width: 66, height: 144)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
            
            Text(title)
                .padding(.top, 5)
                .font(.custom(isSelected ? "OpenSans-SemiBold" : "OpenSans-Regular", size: 15))
                .foregroundColor(isSelected ? .blue : Color("TextColor"))
        }
        .onTapGesture {
            withAnimation {
                settingsViewModel.selectedAppearance = mode
            }
        }
    }
}

#Preview("Logged In State") {
    let mockAuth = AuthViewModel()
    let mockSettings = SettingsViewModel()
    
    UpdateAppearanceView()
        .environmentObject(mockAuth)
        .environmentObject(mockSettings)
}

