import SwiftUI

struct UsernameSelectionView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: SignUpViewModel.Field?

    var body: some View {
        VStack(spacing: 15) {
            AuthInputField(title: "Choose a Username", placeholder: "Username", text: $viewModel.username, field: .username, focusState: $focusedField, borderColor: viewModel.usernameBorderColor)
                .submitLabel(.done)
            
            AuthActionButton(title: "Finish", isLoading: viewModel.isLoading, isDisabled: viewModel.username.isEmpty) {
                focusedField = nil
                Task { await viewModel.finalizeUsername() }
            }
        }
    }
}
