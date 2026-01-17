import SwiftUI

struct UpdateFieldView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    let fieldType: EditFieldType
    @Environment(\.dismiss) var dismiss
    
    @State private var newValue: String = ""

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: fieldType.title, buttonTitle: "Exit") {
                dismiss()
            }

            VStack(spacing: 15) {
                Text(fieldType.subtitle)
                    .font(.custom("OpenSans-SemiBold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("TextColor"))

                TextField(fieldType.placeholder, text: $newValue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("TextFieldBackground"))
                    .cornerRadius(12)
                    .keyboardType(fieldType.keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
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
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            // Pre-fill with existing data
            if fieldType == .username {
                newValue = userViewModel.username
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
                    // Call the global UserViewModel to update Firestore
                    try await userViewModel.updateUsername(to: newValue)
                    dismiss()
                case .email:
                    // EMAIL LOGIC
                    break
                case .phone:
                    break
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
    
    return NavigationView {
        ActivityView()
            .environmentObject(mockAuth)
            .environmentObject(mockSettings)
    }
}

