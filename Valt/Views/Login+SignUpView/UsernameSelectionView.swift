import SwiftUI

struct UsernameSelectionView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: SignUpViewModel.Field?

    var body: some View {
        VStack(spacing: 20) {
            Text("Last Step!")
                .font(.custom("OpenSans-Bold", size: 24))
            
            AuthInputField(
                title: "Username",
                placeholder: "Enter a unique username",
                text: $viewModel.username,
                field: .username,
                focusState: $focusedField
            )
            
            AuthActionButton(
                title: "Finish",
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.username.isEmpty
            ) {
                focusedField = nil
                Task {
                    await viewModel.finalizeUsername()
                }
            }
        }
        .padding(.horizontal, 30)
    }
}
