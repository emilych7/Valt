import SwiftUI

struct DeactivateView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingConfirmation = false
    @State private var password = "" // Store the password input
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SettingsHeader(title: "Delete Account", imageTitle: "exitDynamicIcon", buttonTitle: "Exit") {
                    dismiss()
                }
                
                VStack(spacing: 10) {
                    Text("Deleting Your Valt Account")
                        .padding(.top, 5)
                        .font(.custom("OpenSans-Regular", size: 17))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("TextColor"))
                    
                    Text("Deleting your account is permanent. This will remove your profile, drafts, and bookmarks.")
                        .font(.custom("OpenSans-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("TextColor").opacity(0.7))
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingConfirmation = true
                    } label: {
                        ZStack {
                            if viewModel.isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text("Continue")
                                    .font(.custom("OpenSans-Bold", size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isSaving ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isSaving)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .alert("Confirm Deletion", isPresented: $showingConfirmation) {
            SecureField("Enter Password", text: $password)
            
            Button("Cancel", role: .cancel) {
                password = "" // reset on cancel
            }
            
            Button("Delete Permanently", role: .destructive) {
                executeDeletion(with: password)
            }
        } message: {
            Text("Please enter your password to confirm you want to delete everything.")
        }
    }
    
    private func executeDeletion(with pass: String) {
        Task {
            viewModel.isSaving = true
            do {
                try await viewModel.deleteAccount(password: pass)
                authViewModel.signOut()
                dismiss()
            } catch {
                print("Deletion failed: \(error.localizedDescription)")
            }
            viewModel.isSaving = false
        }
    }
}
