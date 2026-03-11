import SwiftUI
import FirebaseAuth

struct UpdateFieldView: View {
    @EnvironmentObject private var bannerManager: BannerManager
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var tabManager: TabManager
    
    let fieldType: EditFieldType
    
    @State private var newValue: String = ""
    @FocusState private var isFocused: Bool
    
    var dynamicPlaceholder: String {
        settingsViewModel.getPlaceholder(for: fieldType, currentUsername: userViewModel.username)
    }
    
    private var isInputValid: Bool {
        !newValue.isEmpty && newValue != userViewModel.username
    }
    
    private var currentSelectionState: InputStatus {
        fieldType == .username ? settingsViewModel.usernameSelectionState : settingsViewModel.emailSelectionState
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SettingsHeader(title: fieldType.title, buttonTitle: "Exit") {
                    dismiss()
                }
                
                VStack(spacing: 15) {
                    Text(fieldType.subtitle)
                        .font(.custom("OpenSans-SemiBold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("TextColor"))
                    
                    inputFieldRow
                    
                    
                    
                    if let error = settingsViewModel.errorMessage {
                        Text(error)
                            .font(.custom("OpenSans-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("ValtRed").opacity(0.7))
                    } else {
                        Text(fieldType.subtitle2)
                            .font(.custom("OpenSans-Regular", size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("TextColor").opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: handleSave) {
                        ZStack {
                            if settingsViewModel.isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.custom("OpenSans-Bold", size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(currentSelectionState == .valid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isInputValid || settingsViewModel.isSaving || currentSelectionState != .valid)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .padding(.bottom, 30)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onTapGesture { isFocused = false }
        .toolbar { keyboardToolbarItems }
        .onAppear {
            tabManager.setTabBarHidden(true)
            loadInitialValue()
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // Begin subviews
    private var inputFieldRow: some View {
        HStack {
            TextField(dynamicPlaceholder, text: $newValue)
                .padding()
                .font(.custom("OpenSans-Regular", size: 17))
                .frame(maxWidth: .infinity)
                .keyboardType(fieldType.keyboardType)
                .focused($isFocused)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: newValue) { _, val in
                    handleTextChange(val)
                }
            
            statusIndicator
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("TextFieldBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("TextColor").opacity(0.2), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var statusIndicator: some View {
        Group {
            switch currentSelectionState {
            case .idle:
                Color.clear
            case .valid:
                Image("Accepted").resizable()
            case .invalid:
                Image("Caution").resizable()
            case .error:
                Image("Exit").resizable()
            case .loading:
                ProgressView()
                    .controlSize(.small)
                    .tint(Color("TextColor"))
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 18, height: 18)
        .padding(.trailing, 20)
        .padding(.leading, 10)
    }

    private func handleTextChange(_ value: String) {
        if fieldType == .username {
            settingsViewModel.checkUsernameAvailability(for: value, currentUsername: userViewModel.username)
        } else if fieldType == .email {
            let currentEmail = Auth.auth().currentUser?.email ?? ""
            settingsViewModel.checkEmailAvailability(for: value, currentEmail: currentEmail)
        }
    }
    
    private func loadInitialValue() {
        switch fieldType {
        case .username: newValue = userViewModel.username
        case .email:    newValue = Auth.auth().currentUser?.email ?? ""
        }
    }

    private func handleSave() {
        Task {
            settingsViewModel.isSaving = true
            settingsViewModel.errorMessage = nil
            
            do {
                switch fieldType {
                case .username:
                    try await settingsViewModel.updateUsername(to: newValue, oldName: userViewModel.username)
                    userViewModel.username = newValue
                    dismiss()
                    bannerManager.show("Updated Username Successfully", backgroundColor: Color("RequestButtonColor"), icon: "usernameIcon")
                    
                case .email:
                    try await settingsViewModel.updateEmail(to: newValue)
                    settingsViewModel.errorMessage = "Verification email sent! Check your inbox."
                    bannerManager.show("Updated Email Successfully", backgroundColor: Color("RequestButtonColor"), icon: "emailIcon")
                }
            } catch {
                settingsViewModel.errorMessage = error.localizedDescription
            }
            settingsViewModel.isSaving = false
        }
    }
    
    @ToolbarContentBuilder
    private var keyboardToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            Button("Clear") { newValue = "" }.foregroundColor(.red)
        }
        ToolbarItem(placement: .keyboard) { Spacer() }
        ToolbarItem(placement: .keyboard) {
            Button { isFocused = false } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .foregroundColor(Color("TextColor"))
            }
        }
        ToolbarItem(placement: .keyboard) { Spacer() }
        ToolbarItem(placement: .keyboard) {
            Button("Save") { handleSave() }.foregroundColor(Color("TextColor"))
        }
    }
}
