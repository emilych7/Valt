import SwiftUI

struct UsernameSelectionView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: SignUpViewModel.Field?

    var body: some View {
        VStack(spacing: 12) {
            Text("Pick a unique username for your Valt profile. You can change this later.")
                .font(.custom("OpenSans-Regular", size: 14))
                .foregroundColor(Color("TextColor").opacity(0.70))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.bottom, 25)
            
            AuthInputField(
                title: "Username",
                placeholder: "e.g. java_offscript",
                text: $viewModel.username,
                field: .username,
                focusState: $focusedField,
                borderColor: viewModel.usernameBorderColor
            )
            .submitLabel(.done)
            
            if let errorMessage = viewModel.errorMessage {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.red)
                        .padding(.top, 2)
                    
                    Text(errorMessage)
                        .foregroundColor(Color("TextColor"))
                        .font(.custom("OpenSans-Regular", size: 14))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.red.opacity(0.10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.red.opacity(0.25), lineWidth: 1)
                        )
                )
                .padding(.vertical, 2)
            }
            
            AuthActionButton(
                title: "Continue",
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) {
                focusedField = nil
                Task { await viewModel.finalizeUsername() }
            }
            .padding(.top, 4)
        }
    }
}
