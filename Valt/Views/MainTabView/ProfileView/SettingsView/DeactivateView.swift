import SwiftUI

struct DeactivateView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SettingsHeader(title: "Delete Account", buttonTitle: "Exit") {
                    dismiss()
                }
                
                VStack(spacing: 15) {
                    Text("Deleting Your Valt Account")
                        .font(.custom("OpenSans-SemiBold", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color("TextColor"))
                    
                    Text("Deleting your account is permanent. When you delete your Valt account, your profile, drafts, and bookmarks will be permanently removed.")
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
                    
                    // Show Delete Confirmation Button
                    Button {
                        showingConfirmation = true
                    } label: {
                        ZStack {
                            if viewModel.isSaving {
                                ProgressView()
                                    .tint(.white)
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
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
    }
    .scrollBounceBehavior(.basedOnSize)
    .background(Color("AppBackgroundColor").ignoresSafeArea())
    .onAppear {
        // Clear any old error messages
        viewModel.errorMessage = nil
    }
    .alert("Are you absolutely sure?", isPresented: $showingConfirmation) {
        Button("Cancel", role: .cancel) { }
        Button("Delete Everything", role: .destructive) {
            executeDeletion()
        }
    } message: {
        Text("You cannot undo this action.")
    }
    }
    
    private func executeDeletion() {
        Task {
            viewModel.isSaving = true
            do {
                try await viewModel.deleteAccount()
            } catch {
                print("Deletion failed: \(error.localizedDescription)")
            }
            viewModel.isSaving = false
        }
    }
}
