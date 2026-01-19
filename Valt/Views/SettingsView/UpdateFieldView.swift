import SwiftUI
import FirebaseAuth

struct UpdateFieldView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    let fieldType: EditFieldType
    @Environment(\.dismiss) var dismiss
    
    @State private var newValue: String = ""
    
    var dynamicPlaceholder: String {
        settingsViewModel.getPlaceholder(for: fieldType, currentUsername: userViewModel.username)
    }
    
    var body: some View {
        ScrollView {
        VStack(spacing: 0) {
            CustomHeader(title: fieldType.title, buttonTitle: "Exit") {
                dismiss()
            }
            
            VStack(spacing: 15) {
                Text(fieldType.subtitle)
                    .font(.custom("OpenSans-SemiBold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("TextColor"))
                
                HStack {
                    TextField(dynamicPlaceholder, text: $newValue)
                        .padding()
                        .font(.custom("OpenSans-Regular", size: 17))
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .keyboardType(fieldType.keyboardType)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Image("Caution")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .padding(.trailing, 20)
                        .padding(.leading, 10)
                }
                .background(Color("TextFieldBackground"))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("TextFieldBorder"), lineWidth: 1)
                }
                
                Text(fieldType.subtitle2)
                    .font(.custom("OpenSans-Regular", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("TextColor").opacity(0.7))
                
                if let error = settingsViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Spacer()
                
                // Save Button
                Button {
                    handleSave()
                } label: {
                    ZStack {
                        if settingsViewModel.isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save Changes")
                                .font(.custom("OpenSans-Bold", size: 16))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isInputValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isInputValid || settingsViewModel.isSaving)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
    }
    .refreshable {
        // Runs when the user pulls down on the list
        await userViewModel.reloadUser()
    }
    .background(Color("AppBackgroundColor").ignoresSafeArea())
    .navigationBarHidden(true)
    .onAppear {
        switch fieldType {
            case .username: newValue = userViewModel.username
            case .email:    newValue = Auth.auth().currentUser?.email ?? ""
            case .phone:    newValue = Auth.auth().currentUser?.phoneNumber ?? ""
        }
    }
}

    // Computed property for basic validation
    private var isInputValid: Bool {
        !newValue.isEmpty && newValue != userViewModel.username
    }

    private func handleSave() {
            Task {
                settingsViewModel.isSaving = true
                settingsViewModel.errorMessage = nil
                
                do {
                    switch fieldType {
                    case .username:
                        try await settingsViewModel.updateUsername(to: newValue, oldName: userViewModel.username)
                        userViewModel.username = newValue // Sync global UI
                        dismiss()
                        
                    case .email:
                        try await settingsViewModel.updateEmail(to: newValue)
                        settingsViewModel.errorMessage = "Verification email sent! Check your inbox."
                        
                    case .phone:
                        try await settingsViewModel.updatePhone(to: newValue)
                        dismiss()
                    }
                } catch {
                    settingsViewModel.errorMessage = error.localizedDescription
                }
                settingsViewModel.isSaving = false
            }
        }
}

#Preview("Logged In State") {
    let mockAuth = AuthViewModel()
    let mockSettings = SettingsViewModel()
    
    UpdateFieldView(fieldType: .email)
        .environmentObject(mockAuth)
        .environmentObject(mockSettings)
}

